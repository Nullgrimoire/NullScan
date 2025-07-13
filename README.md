# 🔍 NullScan

**NullScan** is a fast, cross-platform Rust tool for scanning TCP ports and grabbing service banners. It supports full scans, top 100/1000 presets, and exports results to Markdown — built for speed, clarity, and recon precision.

## ✨ Features

- 🚀 **Fast Asynchronous Scanning** - Concurrent TCP port scanning with configurable thread limits
- 🎯 **Smart Port Selection** - Top 100/1000 common ports or custom ranges
- 🏷️ **Service Detection** - Automatic service identification for common ports
- 📡 **Banner Grabbing** - Capture service banners and version information
- 📊 **Multiple Export Formats** - JSON, Markdown, and CSV output options
- 🎨 **Rich CLI Interface** - Progress bars and colored output
- ⚡ **High Performance** - Built with Tokio for maximum concurrency
- 🔧 **Configurable** - Timeout, concurrency, and output customization
- 🌐 **Cross-Platform** - Works on Windows, macOS, and Linux

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/nullscan/nullscan.git
cd nullscan

# Build the project
cargo build --release

# Run NullScan
./target/release/nullscan --help
```

### Basic Usage

```bash
# Scan top 100 ports on a target
nullscan --target 192.168.1.1 --top100

# Scan specific ports with banner grabbing
nullscan --target example.com --ports 22,80,443 --banners

# Scan top 1000 ports and export to JSON
nullscan --target 192.168.1.0/24 --top1000 --format json --output scan_results.json

# Custom port range with high concurrency
nullscan --target 10.0.0.1 --ports 1-65535 --concurrency 500 --timeout 1000
```

## 📋 Command Line Options

```
Usage: nullscan [OPTIONS] --target <TARGET>

Options:
  -t, --target <TARGET>            Target IP address or hostname
  -p, --ports <PORTS>              Port range (e.g., 1-1000, 80,443,8080)
      --top100                     Use top 100 most common ports
      --top1000                    Use top 1000 most common ports
  -c, --concurrency <CONCURRENCY>  Number of concurrent threads [default: 100]
  -t, --timeout <TIMEOUT>          Connection timeout in milliseconds [default: 3000]
  -b, --banners                    Grab service banners
  -f, --format <FORMAT>            Export format (json, markdown, csv) [default: markdown]
  -o, --output <OUTPUT>            Output file path
  -v, --verbose                    Verbose output
  -h, --help                       Print help
  -V, --version                    Print version
```

## 📊 Output Formats

### Markdown (Default)
```markdown
# 🔍 NullScan Report

## 📊 Scan Information
- **Target:** 192.168.1.1
- **Total Ports Scanned:** 100
- **Open Ports:** 3
- **Closed Ports:** 97
- **Scan Duration:** 2.45s

## 🟢 Open Ports
| Port | Service | Banner | Response Time |
|------|---------|--------| -------------|
| 22   | SSH     | OpenSSH 8.0 | 45ms |
| 80   | HTTP    | nginx/1.18.0 | 32ms |
| 443  | HTTPS   | nginx/1.18.0 | 38ms |
```

### JSON
```json
{
  "scan_info": {
    "target": "192.168.1.1",
    "total_ports": "100",
    "open_ports": "3",
    "scan_duration": "2.45s"
  },
  "results": [
    {
      "port": 22,
      "is_open": true,
      "service": "SSH",
      "banner": "OpenSSH 8.0",
      "response_time": "45ms"
    }
  ]
}
```

### CSV
```csv
Port,Status,Service,Banner,ResponseTime(ms)
22,Open,"SSH","OpenSSH 8.0",45
80,Open,"HTTP","nginx/1.18.0",32
443,Open,"HTTPS","nginx/1.18.0",38
```

## 🏗️ Architecture

```
src/
├── main.rs          # CLI interface and application entry point
├── scanner/         # Core scanning engine
│   └── mod.rs       # TCP port scanning logic
├── banner/          # Service banner detection
│   └── mod.rs       # Banner grabbing implementation
├── export/          # Output formatting and export
│   └── mod.rs       # JSON, Markdown, CSV exporters
└── presets/         # Port configuration presets
    └── mod.rs       # Top 100/1000 port definitions
```

## 🔧 Configuration

### Environment Variables

```bash
# Set log level
export RUST_LOG=debug

# Custom timeout
export NULLSCAN_TIMEOUT=5000
```

### Concurrency Guidelines

- **Low-spec systems**: 50-100 concurrent connections
- **Standard systems**: 100-500 concurrent connections
- **High-performance**: 500-1000+ concurrent connections
- **Rate limiting**: Use lower concurrency for external targets

## 🛡️ Security Considerations

- **Ethical Use**: Only scan systems you own or have permission to test
- **Rate Limiting**: Adjust concurrency to avoid overwhelming targets
- **Legal Compliance**: Ensure compliance with local laws and regulations
- **Network Impact**: Consider bandwidth usage on large scans

## 🔍 Examples

### Network Discovery
```bash
# Quick host discovery
nullscan --target 192.168.1.0/24 --ports 22,80,443 --timeout 1000

# Comprehensive scan
nullscan --target 10.0.0.1 --top1000 --banners --format json --output results.json
```

### Web Server Analysis
```bash
# Web-focused scan
nullscan --target example.com --ports 80,443,8080,8443 --banners --verbose
```

### Service Enumeration
```bash
# Common services
nullscan --target 192.168.1.100 --ports 21,22,23,25,53,80,110,143,443,993,995 --banners
```

## 🚀 Performance

NullScan is optimized for speed and efficiency:

- **Async I/O**: Non-blocking network operations using Tokio
- **Concurrent Scanning**: Configurable thread pool for parallel execution
- **Memory Efficient**: Minimal memory footprint even for large scans
- **Smart Timeouts**: Adaptive timeout handling for different network conditions

### Benchmarks

| Target | Ports | Concurrency | Time | Rate |
|--------|-------|-------------|------|------|
| localhost | 1000 | 100 | 0.8s | 1,250 ports/s |
| LAN host | 1000 | 200 | 2.1s | 476 ports/s |
| Internet | 100 | 50 | 15.2s | 6.6 ports/s |

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Rust](https://www.rust-lang.org/) and [Tokio](https://tokio.rs/)
- Inspired by classic tools like Nmap and Masscan
- Thanks to the Rust community for excellent crates

## 📞 Support

- 📧 Email: support@nullscan.dev
- 🐛 Issues: [GitHub Issues](https://github.com/nullscan/nullscan/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/nullscan/nullscan/discussions)

---

**⚠️ Disclaimer**: NullScan is intended for legitimate security testing and network administration. Users are responsible for ensuring they have proper authorization before scanning any systems.
