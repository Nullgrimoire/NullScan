use anyhow::Result;
use clap::Parser;
use log::{info, warn};
use std::collections::HashMap;
use std::net::IpAddr;
use std::time::Instant;

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
    /// Target IP address or hostname
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

    /// Connection timeout in milliseconds
    #[arg(short = 't', long, default_value = "3000")]
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

    // Parse target
    let target: IpAddr = match args.target.parse() {
        Ok(ip) => ip,
        Err(_) => {
            // Try to resolve hostname
            let addrs = tokio::net::lookup_host(format!("{}:80", args.target)).await?;
            addrs
                .map(|addr| addr.ip())
                .next()
                .ok_or_else(|| anyhow::anyhow!("Failed to resolve hostname: {}", args.target))?
        }
    };

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
        "Target: {} | Ports: {} | Concurrency: {}",
        target,
        ports.len(),
        args.concurrency
    );

    // Create scan configuration
    let config = ScanConfig {
        target,
        ports,
        concurrency: args.concurrency,
        timeout_ms: args.timeout,
        grab_banners: args.banners,
    };

    // Perform scan
    let start_time = Instant::now();
    let scanner = Scanner::new(config);
    let results = scanner.scan().await?;
    let scan_duration = start_time.elapsed();

    // Generate report
    let report = generate_scan_report(&results, &args.target, scan_duration);

    // Export results
    export::export_results(&results, &report, args.format, args.output).await?;

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
