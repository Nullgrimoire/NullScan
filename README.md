# 🔍 NullScan

**NullScan** is a fast, cross-platform Rust tool for scanning TCP ports and grabbing service banners. It supports full scans, top 100/1000 presets, and exports results to Markdown — built for speed, clarity, and recon precision.

## ✨ Features

- 🚀 **Fast Asynchronous Scanning** - Concurrent TCP port scanning with configurable thread limits
- 🌐 **Network Range Support** - CIDR notation scanning (e.g., `192.168.1.0/24`, `10.0.0.0/16`)
- ⚡ **Parallel Host Scanning** - Scan multiple hosts concurrently with `--max-hosts` for dramatic speed improvements
- 🏓 **Ping Sweep** - Pre-scan host discovery to skip unreachable targets (huge time saver for large networks)
- 🎯 **Smart Port Selection** - Top 100/1000 common ports or custom ranges
- 🏷️ **Advanced Service Detection** - Intelligent protocol probing with confidence scoring
- 📡 **Enhanced Banner Grabbing** - Protocol-specific probes for SSH, TLS, HTTP, databases, and more
- 📊 **Multiple Export Formats** - JSON, Markdown, and CSV output options with IP-grouped results
- 🎨 **Rich CLI Interface** - Progress bars and colored output
- ⚡ **High Performance** - Built with Tokio for maximum concurrency
- 🔧 **Configurable** - Timeout, concurrency, and output customization
- 🌐 **Cross-Platform** - Works on Windows, macOS, and Linux

## 🔍 Service Detection & Protocol Probing

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

# High-speed network scan with parallel hosts and JSON output
nullscan --target 10.0.0.0/24 --top1000 --max-hosts 8 --format json --output network_scan.json

# Multiple targets with ping sweep
nullscan --target "8.8.8.8,8.8.4.4,1.1.1.1" --ping-sweep --ports 53,80,443

# Large network scan with optimal performance
nullscan --target 172.16.0.0/16 --ping-sweep --top100 --max-hosts 20 --concurrency 200
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
  -b, --banners                    Grab service banners
  -f, --format <FORMAT>            Export format (json, markdown, csv) [default: markdown]
  -o, --output <OUTPUT>            Output file path
  -v, --verbose                    Verbose output
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
# Without ping sweep: Scan 256 hosts × 100 ports = 25,600 operations
nullscan --target 192.168.1.0/24 --top100

# With ping sweep: Only scan live hosts (e.g., 12 hosts × 100 ports = 1,200 operations)
nullscan --target 192.168.1.0/24 --ping-sweep --top100
# Result: ~95% reduction in scan time!
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
| Port | Service | Banner | Response Time |
|------|---------|--------|---------------|
| 22   | SSH     | OpenSSH 8.0 | 45ms |
| 80   | HTTP    | Apache/2.4.41 | 23ms |

### 🖥️ Host: 192.168.1.2
| Port | Service | Banner | Response Time |
|------|---------|--------|---------------|
| 443  | HTTPS   | N/A | 18ms |
| 3306 | MySQL   | MySQL 8.0.32 | 12ms |
```

### JSON Output
```json
{
  "target": "192.168.1.1",
  "port": 22,
  "is_open": true,
  "service": "SSH",
  "banner": "SSH-2.0-OpenSSH_8.0",
  "response_time": 45
}
```

### CSV Output
```csv
target,port,is_open,service,banner,response_time
192.168.1.1,22,true,SSH,SSH-2.0-OpenSSH_8.0,45
192.168.1.1,80,true,HTTP,Apache/2.4.41,23
```

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
# Comprehensive scan with banners
nullscan --target 192.168.1.0/24 --ping-sweep --top1000 --banners --max-hosts 5

# Fast reconnaissance
nullscan --target target-range.txt --ping-sweep --top100 --format json
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

---

**Happy Scanning!** 🔍✨
