<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# NullScan - Rust TCP Port Scanner

This is a production-ready Rust application for fast TCP port scanning and service banner grabbing.

## Key Features

-   Fast, asynchronous TCP port scanning with parallel host support
-   Ping sweep functionality for network discovery
-   Service banner detection and grabbing
-   Top 100/1000 port presets
-   Multiple export formats (Markdown, JSON, CSV) with IP-grouped output
-   CIDR network range scanning
-   Comma-separated target support
-   Cross-platform compatibility
-   CLI interface with comprehensive options

## Development Guidelines

-   Use async/await for network operations
-   Implement proper error handling with Result types
-   Follow Rust naming conventions and idioms
-   Use tokio for async runtime
-   Implement comprehensive logging
-   Write unit and integration tests
-   Use clap for CLI argument parsing
-   Ensure cross-platform compatibility

## Architecture

-   `main.rs` - Entry point and CLI setup
-   `scanner/` - Core scanning functionality
-   `banner/` - Service banner detection
-   `export/` - Output formatting and export
-   `presets/` - Port presets and configurations
