# 🔍 NullScan

[![Tests](https://github.com/Nullgrimoire/NullScan/actions/workflows/test.yml/badge.svg)](https://github.com/Nullgrimoire/NullScan/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**NullScan** is a fast, cross-platform Rust tool for scanning TCP ports and grabbing service banners. It supports full scans, top 100/1000 presets, and exports results to Markdown — built for speed, clarity, and recon precision.

## ✨ Features

- 🚀 **Fast Asynchronous Scanning** - Concurrent TCP port scanning with configurable thread limits
- 🌐 **Network Range Support** - CIDR notation scanning (e.g., `192.168.1.0/24`, `10.0.0.0/16`)
- ⚡ **Parallel Host Scanning** - Scan multiple hosts concurrently with `--max-hosts` for dramatic speed improvements
- 🏓 **Ping Sweep** - Pre-scan host discovery to skip unreachable targets (huge time saver for large networks)
- 🎯 **Smart Port Selection** - Top 100/1000 common ports or custom ranges
- 🏷️ **Advanced Service Detection** - Intelligent protocol probing with confidence scoring
- 📡 **Enhanced Banner Grabbing** - Protocol-specific probes for SSH, TLS, HTTP, databases, and more
- 📊 **Multiple Export Formats** - JSON, Markdown, CSV, and HTML output options with IP-grouped results
- 🛡️ **Vulnerability Assessment** - Offline CVE database checking with severity classification
- 🎨 **Rich CLI Interface** - Progress bars and colored output
- ⚡ **High Performance** - Built with Tokio for maximum concurrency
- 🔧 **Configurable** - Timeout, concurrency, and output customization
- 🌐 **Cross-Platform** - Works on Windows, macOS, and Linux

## �️ Vulnerability Assessment

NullScan includes an offline vulnerability database for real-time security assessment:

### Features

- **Offline CVE Database** - Local vulnerability checking with `--vuln-check` flag
- **Pattern Matching** - Regex, substring, and version-based vulnerability detection
- **Severity Classification** - Critical, High, Medium, Low, Info levels with CVSS scoring
- **Real-time Results** - Vulnerabilities displayed in scan output with CVE references
- **Extensible Database** - JSON-based vulnerability database for easy updates

### Example Usage

```bash
# Basic vulnerability scanning
nullscan --target 192.168.1.100 --top100 --banners --vuln-check

# Comprehensive security assessment
nullscan --target 192.168.1.0/24 --top1000 --banners --vuln-check --format html --output security_report.html

# Quick vulnerability check on web services
nullscan --target example.com --ports 80,443,8080 --banners --vuln-check
```

### Sample Output

```bash
# Results show vulnerability information:
# Port 22  | SSH     | SSH-2.0-OpenSSH_7.4 | ⚠️  CVE-2018-15473: SSH Username Enumeration
# Port 80  | HTTP    | Apache/2.4.29       | 🔴 CVE-2019-0211: Apache HTTP Privilege Escalation
# Port 443 | HTTPS   | OpenSSL/1.0.2k      | 🔴 CVE-2016-2107: OpenSSL Padding Oracle Attack
```

## �🔍 Service Detection & Protocol Probing

NullScan uses intelligent protocol-specific probes to accurately identify services, even when they don't send immediate banners:

### Supported Protocols

| Protocol | Ports | Detection Method | Information Gathered |
|----------|-------|------------------|---------------------|
| **SSH** | 22, 2222 | SSH version handshake | SSH version, server software |
| **HTTP** | 80, 8080, 3000, 8000 | HTTP GET request | Status codes, server headers, web technology |
| **HTTPS/TLS** | 443, 8443, 993, 995 | TLS ClientHello | TLS version, certificate information |
| **FTP** | 21 | Banner analysis | FTP server version, welcome message |
| **SMTP** | 25, 587, 465 | SMTP welcome banner | Mail server software, capabilities |
| **DNS** | 53 | DNS version query | DNS server responsiveness |
| **Database** | 3306 (MySQL), 5432 (PostgreSQL), 1433 (MSSQL) | Protocol handshakes | Database version, server info |
| **RDP** | 3389 | RDP connection request | Remote Desktop availability |
| **SMB** | 139, 445 | NetBIOS session request | SMB/CIFS file sharing |

### Enhanced Detection Features

- **Silent Service Discovery**: Detects services that don't announce themselves
- **Confidence Scoring**: Rates detection accuracy (0.0-1.0)
- **Fallback Mechanisms**: Uses multiple detection methods per port
- **Protocol Fingerprinting**: Identifies specific service versions and implementations

### Example Output

```bash
# Advanced protocol detection
nullscan --target 192.168.1.100 --ports 22,80,443,3306 --banners

# Results show enhanced service information:
# Port 22  | SSH     | SSH - SSH-2.0-OpenSSH_8.4p1 Ubuntu-6ubuntu2.1
# Port 80  | HTTP    | HTTP - HTTP/1.1 200 OK Server: nginx/1.18.0
# Port 443 | HTTPS   | TLS/SSL - TLS handshake successful (version: 3.3)
# Port 3306| MySQL   | MySQL - MySQL 8.0.33-0ubuntu0.22.04.2
```

## 🚀 Installation

### Build from Source

**Prerequisites:**
- Rust 1.70+ ([Install Rust](https://rustup.rs/))

```bash
# Clone the repository
git clone https://github.com/Nullgrimoire/NullScan.git
cd NullScan

# Build the project
cargo build --release

# Run NullScan
./target/release/nullscan --help
```

### Install via Cargo

```bash
# Install from GitHub
cargo install --git https://github.com/Nullgrimoire/NullScan.git
```

## 🚀 Quick Start

### Basic Usage

### PowerShell Setup (Windows)

For easier usage in PowerShell, set up an alias:

```powershell
# Set alias for current session
Set-Alias nullscan ".\target\release\nullscan.exe"

# Or add to your PowerShell profile for permanent use
Add-Content $PROFILE "Set-Alias nullscan `"$PWD\target\release\nullscan.exe`""

# Now you can use it directly
nullscan --help
nullscan --target 127.0.0.1 --top100
```

### Basic Usage

```bash
# Scan top 100 ports on a single target
nullscan --target 192.168.1.1 --top100

# Scan a network range with CIDR notation (sequential)
nullscan --target 192.168.1.0/24 --top100

# Fast parallel network scan with 4 concurrent hosts
nullscan --target 192.168.1.0/24 --top100 --max-hosts 4

# Ping sweep before scanning (skip dead hosts)
nullscan --target 10.0.0.0/24 --ping-sweep --top100

# Scan specific ports with banner grabbing
nullscan --target example.com --ports 22,80,443 --banners

# Vulnerability assessment with banner grabbing
nullscan --target 192.168.1.100 --top100 --banners --vuln-check

# High-speed network scan with parallel hosts and JSON output
nullscan --target 10.0.0.0/24 --top1000 --max-hosts 8 --format json --output network_scan.json

# Multiple targets with ping sweep
nullscan --target "8.8.8.8,8.8.4.4,1.1.1.1" --ping-sweep --ports 53,80,443

# Large network scan with optimal performance
nullscan --target 172.16.0.0/16 --ping-sweep --top100 --max-hosts 20 --concurrency 200

# Silent automation mode (no progress bars or logs)
nullscan --target 10.0.0.0/22 --ping-sweep --top100 --quiet --format json --output results.json

# ⚡ LUDICROUS SPEED mode - auto-optimized for maximum performance
nullscan --target 192.168.1.0/24 --fast-mode --top100
# Auto-sets: concurrency=1800 (12-core), timeout=50ms, quiet mode, IP-only, batched scanning
```

## 📋 Command Line Options

```
Usage: nullscan [OPTIONS] --target <TARGET>

Options:
  -t, --target <TARGET>            Target IP address, hostname, or CIDR notation (e.g., 192.168.1.0/24)
                                   Supports comma-separated targets: "IP1,IP2,IP3"
  -p, --ports <PORTS>              Port range (e.g., 1-1000, 80,443,8080)
      --top100                     Use top 100 most common ports
      --top1000                    Use top 1000 most common ports
  -c, --concurrency <CONCURRENCY>  Number of concurrent threads [default: 100]
      --max-hosts <MAX_HOSTS>      Maximum concurrent hosts to scan (for CIDR ranges) [default: 1]
      --ping-sweep                 Perform ping sweep before port scanning (skip unreachable hosts)
      --timeout <TIMEOUT>          Connection timeout in milliseconds [default: 3000]
      --ping-timeout <PING_TIMEOUT> Ping sweep timeout in milliseconds (faster detection for dead hosts) [default: 800]
  -b, --banners                    Grab service banners with intelligent protocol probing
      --vuln-check                 Check for known vulnerabilities based on service banners
  -f, --format <FORMAT>            Export format (json, markdown, csv, html) [default: markdown]
  -o, --output <OUTPUT>            Output file path
  -v, --verbose                    Verbose output
  -q, --quiet                      Quiet mode - suppress progress bars and non-essential output
      --fast-mode                  Fast mode - auto-detect CPU cores and optimize for speed (disables banners, vuln checks, verbose)
  -h, --help                       Print help
  -V, --version                    Print version
```

## 🏓 Ping Sweep Feature

The ping sweep feature is a powerful optimization for large network scans:

- **Smart Detection**: Uses TCP connection attempts to common ports (80, 443, 22, etc.) instead of ICMP
- **Massive Time Savings**: Skip unreachable hosts before port scanning
- **Parallel Processing**: Concurrent ping checks with progress visualization
- **Reliable Results**: Detects hosts even when ICMP is blocked

### Performance Impact

```bash
# Without ping sweep: Scan 1024 hosts × 100 ports = 102,400 operations (4+ minutes with Nmap)
nullscan --target 10.0.0.0/22 --top100

# With ping sweep: Only scan live hosts (dramatic reduction)
nullscan --target 10.0.0.0/22 --ping-sweep --top100
# Result: 2.07 seconds vs 240+ seconds with Nmap - 115x faster!
```

> 📖 **For advanced ping sweep optimization techniques, performance tuning parameters, and technical implementation details, see [docs/ping-sweep-optimization.md](docs/ping-sweep-optimization.md)**

## ⚡ Fast Mode Feature

The `--fast-mode` flag activates **LUDICROUS SPEED** mode with extreme optimizations for maximum reconnaissance performance:

### Auto-Optimization Features

- **CPU Detection**: Automatically detects logical cores on your system
- **Ultra Concurrency**: Sets concurrency to `cores × 150` (e.g., 12 cores = 1800 concurrent connections)
- **Ultra-Aggressive Timing**: Uses 50ms timeout (faster than Nmap -T5)
- **Batched Scanning**: Processes ports in 200-port chunks for optimal efficiency
- **DNS Skip**: Only accepts IP addresses (no hostname resolution overhead)
- **Zero Overhead**: Strips all logging, progress bars, and non-essential operations
- **Feature Disable**: Automatically disables banners, vulnerability checks, and verbose logging

### Performance Benefits

```bash
# Traditional scan
nullscan --target 192.168.1.0/24 --top100 --concurrency 100 --timeout 3000
# Takes: ~30+ seconds

# Fast mode (12-core system) - LUDICROUS SPEED
nullscan --target 192.168.1.0/24 --fast-mode --top100
# Takes: ~2-3 seconds (automatically uses concurrency=1800, timeout=50ms)

# Verified benchmark results (localhost testing):
# • Top 100 ports: 88ms average
# • 1000 ports: 382ms average
# • Competitive with industry-standard tools

# Single host performance comparison
nullscan --target 127.0.0.1 --fast-mode --ports 1-100
# Result: ~88ms (competitive with industry-standard tools!)

nullscan --target 127.0.0.1 --fast-mode --ports 1-1000
# Result: ~382ms (1000 ports in under half a second)
```

### Best Use Cases

- **Quick Network Discovery**: Rapidly identify live hosts and open ports
- **Time-Critical Recon**: When you need results fast during penetration testing
- **Large Network Sweeps**: Scanning /16 or /8 networks efficiently
- **Automation Scripts**: Optimal for CI/CD pipelines and scheduled scanning
- **Competitive Benchmarking**: Performance within 30ms of industry-standard tools

### Fast Mode Limitations

- **IP Addresses Only**: Hostnames are not supported (DNS resolution skipped for speed)
- **No Banner Grabbing**: Service banners are not collected in fast mode
- **No Vulnerability Checks**: CVE scanning is disabled for maximum speed
- **Minimal Logging**: Reduced output for performance (automatically enables quiet mode)

```bash
# Perfect for large network reconnaissance (IP addresses only)
nullscan --target 10.0.0.0/16 --fast-mode --ping-sweep --top100 --output fast_recon.json

# Fast mode vs normal mode comparison
nullscan --target 192.168.1.100 --fast-mode --top100        # ~60ms, IP only
nullscan --target example.com --top100 --banners            # ~3s+, full features
```

## 📊 Output Formats

### Markdown (Default)

#### Single Host
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
|------|---------|--------|---------------|
| 22   | SSH     | OpenSSH 8.0 | 45ms |
| 80   | HTTP    | Apache/2.4.41 | 23ms |
| 443  | HTTPS   | N/A | 18ms |
```

#### Multiple Hosts (IP-Grouped)
```markdown
# 🔍 NullScan Report

## 📊 Scan Information
- **Target:** 192.168.1.0/24 (3 hosts)
- **Total Ports Scanned:** 300
- **Open Ports:** 8
- **Closed Ports:** 292
- **Scan Duration:** 4.23s

## 🟢 Open Ports

### 🖥️ Host: 192.168.1.1
| Port | Service | Banner | Response Time | Vulnerabilities |
|------|---------|--------|---------------|----------------|
| 22   | SSH     | OpenSSH 8.0 | 45ms | None |
| 80   | HTTP    | Apache/2.4.41 | 23ms | 🔴 CVE-2019-0211 (High) |

### 🖥️ Host: 192.168.1.2
| Port | Service | Banner | Response Time | Vulnerabilities |
|------|---------|--------|---------------|----------------|
| 443  | HTTPS   | N/A | 18ms | None |
| 3306 | MySQL   | MySQL 8.0.32 | 12ms | None |
```

### JSON Output
```json
{
  "target": "192.168.1.1",
  "port": 22,
  "is_open": true,
  "service": "SSH",
  "banner": "SSH-2.0-OpenSSH_8.0",
  "response_time": 45,
  "vulnerabilities": []
}
```

### CSV Output
```csv
Port,Status,Service,Banner,ResponseTime(ms),Vulnerabilities
22,Open,"SSH","SSH-2.0-OpenSSH_8.0",45,"None"
80,Open,"HTTP","Apache/2.4.41",23,"CVE-2019-0211 (High)"
```

### HTML Output

Interactive HTML reports perfect for penetration testing documentation:

```bash
# Generate professional HTML report
nullscan --target 192.168.1.0/24 --top100 --format html --output pentest_report.html --banners

# Single host with detailed banner information
nullscan --target example.com --ports 80,443,22 --format html --output target_scan.html --banners
```

**Features:**

- 🎨 **Professional Styling** - Clean, modern interface with responsive design
- 📊 **Interactive Tables** - Click to sort by port, service, banner, or response time
- 📂 **IP-Grouped Results** - Organized by host for multi-target scans
- 📋 **Copy to Clipboard** - Export results for external analysis
- ⏰ **User-Friendly Timestamps** - Local time formatting (e.g., "July 13, 2025 at 09:43:18 PM (UTC -07:00)")
- 🔍 **Vulnerability Integration** - CVE information displayed with color-coded severity levels
- 🗂️ **Collapsible Sections** - Expand/collapse individual hosts or entire report
- 📋 **Copy-Paste Ready** - Export results to clipboard for easy inclusion in reports
- 📱 **Mobile Friendly** - Responsive design works on all devices
- 🎯 **IP Grouping** - Multi-host scans organized by target IP address

The HTML format generates professional reports suitable for security assessments and penetration testing documentation.

## 🎯 Common Use Cases


### Network Discovery
```bash
# Find all live hosts in a network
nullscan --target 10.0.0.0/24 --ping-sweep --ports 80,443,22 --format json

# Quick network overview
nullscan --target 192.168.1.0/24 --ping-sweep --top100 --max-hosts 10
```

### Service Enumeration
```bash
# Web service discovery
nullscan --target company.com --ports 80,443,8080,8443 --banners

# Database service scan
nullscan --target db-server.local --ports 3306,5432,1433,27017 --banners
```

### Security Assessment
```bash
# Comprehensive scan with banners and vulnerability checking
nullscan --target 192.168.1.0/24 --ping-sweep --top1000 --banners --vuln-check --max-hosts 5

# Security assessment with HTML report
nullscan --target target-server.com --top100 --banners --vuln-check --format html --output security_audit.html

# Fast reconnaissance with vulnerability analysis
nullscan --target 10.0.0.0/24 --ping-sweep --top100 --banners --vuln-check --format json
```

## 🔧 Performance Optimization

### Parallel Host Scanning
- Use `--max-hosts` to scan multiple hosts concurrently
- Recommended: 4-8 for small networks, 10-20 for large networks
- Balance between speed and resource usage

### Ping Sweep Benefits
- Essential for large networks (/16, /8)
- Reduces scan time by 80-95% on typical networks
- Uses reliable TCP-based host detection

### Concurrency Tuning
- `--concurrency`: Number of simultaneous port connections per host
- Default: 100 (good for most cases)
- Increase for faster scans, decrease for slower/unstable networks

## ⚡ Performance Benchmarks

NullScan is designed for speed and efficiency. Here are some performance comparisons:

### Speed Comparison

| Scanner | Single Host (100 ports) | Network /22 (Top 100) | Large Range (1000 ports) |
|---------|----------------------|----------------------|---------------------|
| **NullScan** | **0.15s** | **2.07s** | **0.31s** |
| Nmap | 0.10s | 240.01s | 1.40s |
| Performance | 1.5x slower | **🔥 115x faster** | **4.5x faster** |

*Latest benchmarks (July 2025): Windows 11, real network testing*
*Network test: 10.0.0.0/22 (1024 potential hosts) with ping sweep optimization*

### Key Performance Features

- **🚀 Tokio Async Runtime**: Non-blocking I/O for maximum concurrency
- **🎯 Smart Resource Management**: Configurable concurrency limits prevent system overload
- **⚡ Parallel Host Processing**: Scan multiple targets simultaneously
- **🏓 Intelligent Ping Sweep**: Skip dead hosts to focus on live targets
- **💾 Memory Efficient**: Low memory footprint even with high concurrency

For detailed performance comparisons with other scanners, see [docs/benchmarks.md](docs/benchmarks.md).

### Real-World Performance

```bash
# Example: Large network discovery
nullscan --target 10.0.0.0/22 --ping-sweep --top100 --ping-timeout 300

# Result: 1024 potential hosts scanned in 2.07 seconds
# Compared to Nmap: 240+ seconds (4+ minutes) - 115x improvement!
```

### Benchmark Your Environment

Want to test NullScan's performance in your environment? Use our included benchmark scripts:

```bash
# Windows PowerShell
.\scripts\benchmark.ps1 -Target "127.0.0.1" -Iterations 3

# Linux/Unix
./scripts/benchmark.sh 127.0.0.1 192.168.1.0/24 3

# Quick local benchmark
time nullscan --target 127.0.0.1 --ports 1-1000

# Network discovery speed test
time nullscan --target 192.168.1.0/24 --ping-sweep --ports 22,80,443

# Large-scale performance test
time nullscan --target 10.0.0.0/24 --top100 --max-hosts 10 --concurrency 200
```

### Why NullScan is Fast

- **🚀 Async I/O**: Non-blocking operations with Tokio runtime
- **🎯 Smart Concurrency**: Optimal resource utilization without overwhelming targets
- **📡 Efficient Protocols**: Minimal overhead for banner grabbing and service detection
- **🏓 Intelligent Filtering**: Ping sweep eliminates dead hosts before port scanning
- **💾 Memory Efficient**: Low memory footprint even with high concurrency

**Benchmark Results (localhost, 1000 ports):**
- NullScan: ~20.5 seconds
- Typical performance: 45-50 ports/second with full banner grabbing

## 🏗️ Architecture

### Core Components
- **Scanner Engine**: Async TCP port scanning with Tokio
- **Banner Grabber**: Service fingerprinting and version detection
- **Export System**: Multiple output formats with IP grouping
- **Progress Tracking**: Real-time scan progress with indicators

### Technologies Used
- **Rust**: Memory-safe systems programming
- **Tokio**: Async runtime for high concurrency
- **Clap**: Command-line argument parsing
- **Serde**: JSON serialization/deserialization
- **Indicatif**: Progress bars and spinners

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ in Rust
- Inspired by classic network scanning tools
- Thanks to the Rust community for excellent async libraries

## � Documentation

For comprehensive technical documentation and development guides, visit the **[docs/](docs/)** directory:

- **[Performance Benchmarks](docs/benchmarks.md)** - Detailed performance comparisons with industry tools
- **[Ping Sweep Optimization](docs/ping-sweep-optimization.md)** - Technical deep-dive into network scanning algorithms

## �💖 Support

If you find NullScan helpful, consider supporting the project:

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support%20Development-orange?style=flat-square&logo=buy-me-a-coffee)](https://coff.ee/nullgrimoire)

Your support helps maintain and improve NullScan for the community! 🚀

---

**Happy Scanning!** 🔍✨
