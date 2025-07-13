use anyhow::Result;
use log::debug;
use std::time::Duration;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;
use tokio::time::timeout;

#[derive(Debug, Clone)]
pub struct BannerGrabber {
    timeout_ms: u64,
}

impl BannerGrabber {
    pub fn new() -> Self {
        Self {
            timeout_ms: 5000, // 5 seconds for banner grabbing
        }
    }

    pub async fn grab_banner(&self, mut stream: TcpStream, port: u16) -> Result<String> {
        let timeout_duration = Duration::from_millis(self.timeout_ms);

        // Send appropriate probe based on port
        let probe = get_probe_for_port(port);

        if let Some(probe_data) = probe {
            debug!("Sending probe to port {port}");
            let _ = timeout(timeout_duration, stream.write_all(probe_data.as_bytes())).await;
        }

        // Read response
        let mut buffer = vec![0; 1024];
        if let Ok(Ok(bytes_read)) = timeout(timeout_duration, stream.read(&mut buffer)).await {
            if bytes_read > 0 {
                let banner = String::from_utf8_lossy(&buffer[..bytes_read])
                    .trim()
                    .replace('\r', "")
                    .replace('\n', " ")
                    .to_string();

                if !banner.is_empty() {
                    debug!("Grabbed banner from port {port}: {banner}");
                    return Ok(banner);
                }
            }
        }

        Err(anyhow::anyhow!("No banner received"))
    }
}

fn get_probe_for_port(port: u16) -> Option<&'static str> {
    match port {
        21 => None, // FTP sends banner immediately
        22 => None, // SSH sends banner immediately
        25 => None, // SMTP sends banner immediately
        80 => Some("GET / HTTP/1.1\r\nHost: \r\n\r\n"),
        443 => Some("GET / HTTP/1.1\r\nHost: \r\n\r\n"),
        110 => None, // POP3 sends banner immediately
        143 => None, // IMAP sends banner immediately
        993 => None, // IMAPS - would need TLS
        995 => None, // POP3S - would need TLS
        8080 => Some("GET / HTTP/1.1\r\nHost: \r\n\r\n"),
        8443 => Some("GET / HTTP/1.1\r\nHost: \r\n\r\n"),
        _ => None,
    }
}
