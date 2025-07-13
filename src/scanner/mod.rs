use anyhow::Result;
use futures::future::join_all;
use indicatif::{ProgressBar, ProgressStyle};
use log::{debug, info, warn};
use std::net::{IpAddr, SocketAddr};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::net::TcpStream;
use tokio::time::timeout;

use crate::banner::BannerGrabber;

/// Ping a host to check if it's reachable
pub async fn ping_host(target: IpAddr, timeout_ms: u64) -> bool {
    debug!("Pinging {target}");

    // For IPv4, try TCP connect to common ports (80, 443, 22) as a ping substitute
    // This is more reliable than ICMP ping which often gets blocked
    let common_ports = [80, 443, 22, 21, 25, 53, 110, 143, 993, 995];

    for port in common_ports {
        let addr = SocketAddr::new(target, port);

        match timeout(
            Duration::from_millis(timeout_ms / 2),
            TcpStream::connect(addr),
        )
        .await
        {
            Ok(Ok(_)) => {
                debug!("Host {target} is reachable (TCP connect to port {port})");
                return true;
            }
            Ok(Err(_)) => {
                // Connection refused - host is up but port is closed
                debug!("Host {target} is reachable (connection refused on port {port})");
                return true;
            }
            Err(_) => {
                // Timeout - try next port
                continue;
            }
        }
    }

    debug!("Host {target} appears to be unreachable");
    false
}

/// Perform ping sweep on multiple hosts
pub async fn ping_sweep(targets: &[IpAddr], timeout_ms: u64, concurrency: usize) -> Vec<IpAddr> {
    info!("🏓 Starting ping sweep for {} hosts", targets.len());

    let progress = ProgressBar::new(targets.len() as u64);
    progress.set_style(
        ProgressStyle::default_bar()
            .template("{spinner:.green} [{elapsed_precise}] [{wide_bar:.cyan/blue}] {pos}/{len} hosts ({eta})")
            .unwrap()
            .progress_chars("#>-"),
    );

    let semaphore = Arc::new(tokio::sync::Semaphore::new(concurrency));
    let mut tasks = Vec::new();

    for target in targets {
        let target = *target;
        let semaphore = semaphore.clone();
        let progress = progress.clone();

        let task = tokio::spawn(async move {
            let _permit = semaphore.acquire().await.unwrap();
            let is_alive = ping_host(target, timeout_ms).await;
            progress.inc(1);

            if is_alive {
                Some(target)
            } else {
                None
            }
        });

        tasks.push(task);
    }

    let results = join_all(tasks).await;
    progress.finish_with_message("Ping sweep completed");

    let alive_hosts: Vec<IpAddr> = results
        .into_iter()
        .filter_map(|r| r.ok().flatten())
        .collect();

    info!(
        "✅ Ping sweep found {}/{} hosts alive",
        alive_hosts.len(),
        targets.len()
    );
    alive_hosts
}

#[derive(Debug, Clone)]
pub struct ScanConfig {
    pub target: IpAddr,
    pub ports: Vec<u16>,
    pub concurrency: usize,
    pub timeout_ms: u64,
    pub grab_banners: bool,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ScanResult {
    pub target: IpAddr,
    pub port: u16,
    pub is_open: bool,
    pub service: Option<String>,
    pub banner: Option<String>,
    #[serde(with = "duration_millis")]
    pub response_time: Duration,
}

mod duration_millis {
    use serde::{Deserialize, Deserializer, Serializer};
    use std::time::Duration;

    pub fn serialize<S>(duration: &Duration, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_u64(duration.as_millis() as u64)
    }

    pub fn deserialize<'de, D>(deserializer: D) -> Result<Duration, D::Error>
    where
        D: Deserializer<'de>,
    {
        let millis = u64::deserialize(deserializer)?;
        Ok(Duration::from_millis(millis))
    }
}

pub struct Scanner {
    config: ScanConfig,
    banner_grabber: BannerGrabber,
}

impl Scanner {
    pub fn new(config: ScanConfig) -> Self {
        Self {
            config,
            banner_grabber: BannerGrabber::new(),
        }
    }

    pub async fn scan(&self) -> Result<Vec<ScanResult>> {
        let total_ports = self.config.ports.len();
        info!(
            "🔍 Scanning {} ports on {}",
            total_ports, self.config.target
        );

        // Create progress bar
        let pb = ProgressBar::new(total_ports as u64);
        pb.set_style(
            ProgressStyle::default_bar()
                .template("{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {pos}/{len} ports ({eta})")?
                .progress_chars("#>-"),
        );

        // Create semaphore for concurrency control
        let semaphore = Arc::new(tokio::sync::Semaphore::new(self.config.concurrency));

        // Create scan tasks
        let tasks: Vec<_> = self
            .config
            .ports
            .iter()
            .map(|&port| {
                let config = self.config.clone();
                let semaphore = semaphore.clone();
                let pb = pb.clone();
                let banner_grabber = self.banner_grabber.clone();

                tokio::spawn(async move {
                    let _permit = semaphore.acquire().await.unwrap();
                    let result = scan_port(
                        config.target,
                        port,
                        config.timeout_ms,
                        &banner_grabber,
                        config.grab_banners,
                    )
                    .await;
                    pb.inc(1);
                    result
                })
            })
            .collect();

        // Wait for all tasks to complete
        let results = join_all(tasks).await;
        pb.finish_with_message("Scan completed");

        // Collect results
        let mut scan_results = Vec::new();
        for result in results {
            match result {
                Ok(scan_result) => scan_results.push(scan_result),
                Err(e) => warn!("Task error: {e}"),
            }
        }

        // Sort by port number
        scan_results.sort_by_key(|r| r.port);

        Ok(scan_results)
    }
}

async fn scan_port(
    target: IpAddr,
    port: u16,
    timeout_ms: u64,
    banner_grabber: &BannerGrabber,
    grab_banners: bool,
) -> ScanResult {
    let start_time = Instant::now();
    let socket_addr = SocketAddr::new(target, port);

    debug!("Scanning port {port}");

    let timeout_duration = Duration::from_millis(timeout_ms);

    match timeout(timeout_duration, TcpStream::connect(socket_addr)).await {
        Ok(Ok(stream)) => {
            let response_time = start_time.elapsed();
            debug!("Port {} is open ({}ms)", port, response_time.as_millis());

            let mut result = ScanResult {
                target,
                port,
                is_open: true,
                service: get_service_name(port),
                banner: None,
                response_time,
            };

            // Grab banner if requested
            if grab_banners {
                if let Ok(banner) = banner_grabber.grab_banner(stream, port).await {
                    result.banner = Some(banner);
                }
            }

            result
        }
        Ok(Err(_)) | Err(_) => {
            let response_time = start_time.elapsed();
            debug!("Port {port} is closed/filtered");
            ScanResult {
                target,
                port,
                is_open: false,
                service: None,
                banner: None,
                response_time,
            }
        }
    }
}

fn get_service_name(port: u16) -> Option<String> {
    let service = match port {
        21 => "FTP",
        22 => "SSH",
        23 => "Telnet",
        25 => "SMTP",
        53 => "DNS",
        80 => "HTTP",
        110 => "POP3",
        135 => "RPC",
        139 => "NetBIOS",
        143 => "IMAP",
        443 => "HTTPS",
        445 => "SMB",
        993 => "IMAPS",
        995 => "POP3S",
        1433 => "MSSQL",
        3306 => "MySQL",
        3389 => "RDP",
        5432 => "PostgreSQL",
        5900 => "VNC",
        8080 => "HTTP-Alt",
        8443 => "HTTPS-Alt",
        _ => return None,
    };
    Some(service.to_string())
}
