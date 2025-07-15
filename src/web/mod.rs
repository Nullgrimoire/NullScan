use axum::{
    extract::{Query, State},
    http::StatusCode,
    response::{Html, IntoResponse},
    routing::{get, post},
    Json, Router,
};
use dashmap::DashMap;
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;
use std::sync::Arc;
use tokio::sync::RwLock;
use tower_http::cors::CorsLayer;
use tower_http::services::ServeDir;
use uuid::Uuid;

use crate::scanner::{ScanConfig, ScanResult};
use crate::export::ExportFormat;

mod dashboard;
mod handlers;
mod state;
mod types;

pub use dashboard::*;
pub use handlers::*;
pub use state::*;
pub use types::*;

#[derive(Clone)]
pub struct WebServer {
    pub state: Arc<AppState>,
}

impl WebServer {
    pub fn new() -> Self {
        Self {
            state: Arc::new(AppState::new()),
        }
    }

    pub async fn start(&self, bind_addr: String, port: u16) -> anyhow::Result<()> {
        let addr = format!("{}:{}", bind_addr, port);
        let socket_addr: SocketAddr = addr.parse()?;

        let app = Router::new()
            // API routes
            .route("/api/scan", post(start_scan))
            .route("/api/scans", get(list_scans))
            .route("/api/scan/:id", get(get_scan))
            .route("/api/scan/:id/results", get(get_scan_results))
            .route("/api/scan/:id/stop", post(stop_scan))
            .route("/api/scan/:id/export", get(export_scan))
            .route("/api/health", get(health_check))
            // Dashboard routes
            .route("/", get(dashboard_index))
            .route("/dashboard", get(dashboard_index))
            .route("/scan/:id", get(dashboard_scan_detail))
            // Static files
            .nest_service("/static", ServeDir::new("src/web/static"))
            .with_state(self.state.clone())
            .layer(CorsLayer::permissive());

        println!("🌐 NullScan Web Dashboard starting at http://{}", addr);
        println!("🔍 Red Team Interface: http://{}/dashboard", addr);

        let listener = tokio::net::TcpListener::bind(socket_addr).await?;
        axum::serve(listener, app).await?;

        Ok(())
    }
}
