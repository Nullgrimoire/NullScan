use anyhow::Result;
use clap::Parser;
use log::{info, warn};
use std::collections::HashMap;
use std::net::IpAddr;
use std::sync::Arc;
use std::time::Instant;
use tokio::sync::Semaphore;

mod banner;
mod export;
mod presets;
mod scanner;

use export::ExportFormat;
use presets::PortPreset;
use scanner::{ScanConfig, ScanResult, Scanner};

#[derive(Parser)]
#[command(name = "nullscan")]
#[command(
    about = "A fast, cross-platform Rust tool for scanning TCP ports and grabbing service banners"
)]
#[command(version = "1.0.0")]
struct Args {
    /// Target IP address, hostname, or CIDR notation (e.g., 192.168.1.0/24)
    #[arg(short, long)]
    target: String,

    /// Port range (e.g., 1-1000, 80,443,8080)
    #[arg(short, long)]
    ports: Option<String>,

    /// Use top 100 most common ports
    #[arg(long, conflicts_with = "ports")]
    top100: bool,

    /// Use top 1000 most common ports
    #[arg(long, conflicts_with = "ports")]
    top1000: bool,

    /// Number of concurrent threads
    #[arg(short = 'c', long, default_value = "100")]
    concurrency: usize,

    /// Maximum concurrent hosts to scan (for CIDR ranges)
    #[arg(long, default_value = "1")]
    max_hosts: usize,

    /// Connection timeout in milliseconds
    #[arg(long, default_value = "3000")]
    timeout: u64,

    /// Grab service banners
    #[arg(short = 'b', long)]
    banners: bool,

    /// Export format (json, markdown, csv)
    #[arg(short = 'f', long, default_value = "markdown")]
    format: ExportFormat,

    /// Output file path
    #[arg(short, long)]
    output: Option<String>,

    /// Verbose output
    #[arg(short, long)]
    verbose: bool,
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();

    // Initialize logger
    if args.verbose {
        env_logger::Builder::from_default_env()
            .filter_level(log::LevelFilter::Debug)
            .init();
    } else {
        env_logger::Builder::from_default_env()
            .filter_level(log::LevelFilter::Info)
            .init();
    }

    info!("🚀 NullScan v1.0.0 - Starting port scan");

    // Parse targets
    let targets = parse_targets(&args.target).await?;
    info!("Parsed {} target(s) from: {}", targets.len(), args.target);

    // Determine ports to scan
    let ports = if args.top100 {
        presets::get_top_ports(PortPreset::Top100)
    } else if args.top1000 {
        presets::get_top_ports(PortPreset::Top1000)
    } else if let Some(port_spec) = args.ports {
        parse_port_specification(&port_spec)?
    } else {
        // Default to top 100 if no ports specified
        warn!("No ports specified, using top 100 common ports");
        presets::get_top_ports(PortPreset::Top100)
    };

    info!(
        "Targets: {} | Ports: {} | Concurrency: {} | Max Hosts: {}",
        targets.len(),
        ports.len(),
        args.concurrency,
        args.max_hosts
    );

    // Scan all targets with parallel host scanning
    let start_time = Instant::now();

    // Create semaphore to limit concurrent host scans
    let host_semaphore = Arc::new(Semaphore::new(args.max_hosts));

    // Create futures for all target scans
    let scan_futures = targets.iter().enumerate().map(|(i, target)| {
        let host_semaphore = Arc::clone(&host_semaphore);
        let ports = ports.clone();
        let target = *target;
        let concurrency = args.concurrency;
        let timeout = args.timeout;
        let grab_banners = args.banners;
        let total_targets = targets.len();

        async move {
            // Acquire semaphore permit
            let _permit = host_semaphore.acquire().await.unwrap();

            info!("📡 Scanning target {}/{}: {}", i + 1, total_targets, target);

            // Create scan configuration for this target
            let config = ScanConfig {
                target,
                ports,
                concurrency,
                timeout_ms: timeout,
                grab_banners,
            };

            // Perform scan
            let scanner = Scanner::new(config);
            let results = scanner.scan().await?;

            Ok::<(String, Vec<ScanResult>), anyhow::Error>((target.to_string(), results))
        }
    });

    // Execute all scans concurrently and collect results
    let all_results = futures::future::try_join_all(scan_futures).await?;

    let scan_duration = start_time.elapsed();

    // Generate and export results
    if targets.len() == 1 {
        // Single target - use existing format
        let (target_str, results) = &all_results[0];
        let report = generate_scan_report(results, target_str, scan_duration);
        export::export_results(results, &report, args.format, args.output).await?;
    } else {
        // Multiple targets - combine results
        let mut combined_results = Vec::new();

        for (target_str, results) in &all_results {
            let open_count = results.iter().filter(|r| r.is_open).count();

            info!(
                "📊 {}: {}/{} ports open",
                target_str,
                open_count,
                results.len()
            );
            combined_results.extend(results.iter().cloned());
        }

        let report = generate_network_scan_report(&all_results, &args.target, scan_duration);
        export::export_results(&combined_results, &report, args.format, args.output).await?;
    }

    info!("✅ Scan completed in {scan_duration:.2?}");
    Ok(())
}

fn parse_port_specification(spec: &str) -> Result<Vec<u16>> {
    let mut ports = Vec::new();

    for part in spec.split(',') {
        let part = part.trim();
        if part.contains('-') {
            // Range (e.g., "1-1000")
            let range_parts: Vec<&str> = part.split('-').collect();
            if range_parts.len() != 2 {
                return Err(anyhow::anyhow!("Invalid port range: {}", part));
            }
            let start: u16 = range_parts[0].parse()?;
            let end: u16 = range_parts[1].parse()?;
            for port in start..=end {
                ports.push(port);
            }
        } else {
            // Single port
            let port: u16 = part.parse()?;
            ports.push(port);
        }
    }

    Ok(ports)
}

/// Parse target specification and return list of IP addresses
async fn parse_targets(target_spec: &str) -> Result<Vec<IpAddr>> {
    let mut targets = Vec::new();

    // Check if it's CIDR notation
    if target_spec.contains('/') {
        let network: ipnet::IpNet = target_spec
            .parse()
            .map_err(|_| anyhow::anyhow!("Invalid CIDR notation: {}", target_spec))?;

        // Collect all IPs in the network (limit to reasonable size)
        let mut count = 0;
        for ip in network.hosts() {
            if count >= 1024 {
                warn!("Network too large, limiting to first 1024 hosts");
                break;
            }
            targets.push(ip);
            count += 1;
        }

        if targets.is_empty() {
            return Err(anyhow::anyhow!(
                "No hosts found in network: {}",
                target_spec
            ));
        }
    } else {
        // Single IP or hostname
        match target_spec.parse::<IpAddr>() {
            Ok(ip) => targets.push(ip),
            Err(_) => {
                // Try to resolve hostname
                let resolved = tokio::net::lookup_host(format!("{}:80", target_spec))
                    .await
                    .map_err(|_| anyhow::anyhow!("Failed to resolve hostname: {}", target_spec))?;

                if let Some(addr) = resolved.map(|addr| addr.ip()).next() {
                    targets.push(addr);
                } else {
                    return Err(anyhow::anyhow!(
                        "No addresses found for hostname: {}",
                        target_spec
                    ));
                }
            }
        }
    }

    Ok(targets)
}

fn generate_scan_report(
    results: &[ScanResult],
    target: &str,
    duration: std::time::Duration,
) -> HashMap<String, String> {
    let mut report = HashMap::new();

    let total_ports = results.len();
    let open_ports = results.iter().filter(|r| r.is_open).count();
    let closed_ports = total_ports - open_ports;

    report.insert("target".to_string(), target.to_string());
    report.insert("total_ports".to_string(), total_ports.to_string());
    report.insert("open_ports".to_string(), open_ports.to_string());
    report.insert("closed_ports".to_string(), closed_ports.to_string());
    report.insert("scan_duration".to_string(), format!("{duration:.2?}"));
    report.insert("timestamp".to_string(), chrono::Utc::now().to_rfc3339());

    report
}

fn generate_network_scan_report(
    all_results: &[(String, Vec<ScanResult>)],
    target_spec: &str,
    duration: std::time::Duration,
) -> HashMap<String, String> {
    let mut report = HashMap::new();

    let total_targets = all_results.len();
    let total_ports: usize = all_results.iter().map(|(_, results)| results.len()).sum();
    let total_open_ports: usize = all_results
        .iter()
        .map(|(_, results)| results.iter().filter(|r| r.is_open).count())
        .sum();

    report.insert(
        "target".to_string(),
        format!("{} ({} hosts)", target_spec, total_targets),
    );
    report.insert("total_targets".to_string(), total_targets.to_string());
    report.insert("total_ports".to_string(), total_ports.to_string());
    report.insert("open_ports".to_string(), total_open_ports.to_string());
    report.insert(
        "closed_ports".to_string(),
        (total_ports - total_open_ports).to_string(),
    );
    report.insert("scan_duration".to_string(), format!("{duration:.2?}"));
    report.insert("timestamp".to_string(), chrono::Utc::now().to_rfc3339());

    report
}
