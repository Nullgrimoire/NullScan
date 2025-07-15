use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::scanner::ScanResult;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScanRequest {
    pub target: String,
    pub ports: Option<String>,
    pub top100: bool,
    pub top1000: bool,
    pub concurrency: Option<usize>,
    pub max_hosts: Option<usize>,
    pub ping_sweep: bool,
    pub timeout: Option<u64>,
    pub ping_timeout: Option<u64>,
    pub banners: bool,
    pub vuln_check: bool,
    pub fast_mode: bool,
    pub name: Option<String>,
    pub description: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScanInfo {
    pub id: Uuid,
    pub name: String,
    pub description: String,
    pub target: String,
    pub status: ScanStatus,
    pub created_at: DateTime<Utc>,
    pub started_at: Option<DateTime<Utc>>,
    pub completed_at: Option<DateTime<Utc>>,
    pub progress: ScanProgress,
    pub config: ScanConfig,
    pub results: Vec<ScanResult>,
    pub error: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScanConfig {
    pub target: String,
    pub ports: Vec<u16>,
    pub concurrency: usize,
    pub max_hosts: usize,
    pub ping_sweep: bool,
    pub timeout: u64,
    pub ping_timeout: u64,
    pub banners: bool,
    pub vuln_check: bool,
    pub fast_mode: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub enum ScanStatus {
    #[default]
    Pending,
    Running,
    Completed,
    Failed,
    Stopped,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScanProgress {
    pub current_host: Option<String>,
    pub hosts_completed: usize,
    pub total_hosts: usize,
    pub ports_scanned: usize,
    pub total_ports: usize,
    pub open_ports: usize,
    pub elapsed_seconds: f64,
    pub estimated_remaining: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScanSummary {
    pub total_scans: usize,
    pub active_scans: usize,
    pub completed_scans: usize,
    pub failed_scans: usize,
    pub total_hosts_scanned: usize,
    pub total_ports_scanned: usize,
    pub total_open_ports: usize,
    pub total_vulnerabilities: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApiResponse<T> {
    pub success: bool,
    pub data: Option<T>,
    pub error: Option<String>,
    pub timestamp: DateTime<Utc>,
}

impl<T> ApiResponse<T> {
    pub fn success(data: T) -> Self {
        Self {
            success: true,
            data: Some(data),
            error: None,
            timestamp: Utc::now(),
        }
    }

    pub fn error(error: String) -> Self {
        Self {
            success: false,
            data: None,
            error: Some(error),
            timestamp: Utc::now(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExportRequest {
    pub format: String,
    pub include_closed: bool,
    pub include_banners: bool,
    pub include_vulnerabilities: bool,
}

impl Default for ScanProgress {
    fn default() -> Self {
        Self {
            current_host: None,
            hosts_completed: 0,
            total_hosts: 0,
            ports_scanned: 0,
            total_ports: 0,
            open_ports: 0,
            elapsed_seconds: 0.0,
            estimated_remaining: None,
        }
    }
}
