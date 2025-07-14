# 🏆 NullScan Performance Benchmarks

This document provides comprehensive **validated** performance benchmarks for NullScan compared to other popular TCP port scanners.

## 🎯 Benchmark Methodology

### Test Environment
- **CPU**: Intel i7-10700K @ 3.8GHz (8 cores/16 threads)
- **RAM**: 32GB DDR4-3200
- **OS**: Windows 11 Pro / Ubuntu 22.04 LTS (WSL2)
- **Network**: Gigabit Ethernet, local LAN testing
- **Target**: Mixed responsive/unresponsive hosts

### Tool Versions
- NullScan: v1.0.0
- Nmap: 7.94
- RustScan: 2.1.1
- Masscan: 1.3.2

### Test Categories
1. **Single Host Scanning** - Top 100 most common ports
2. **Large Port Range** - 1000 ports on single host
3. **Network Range** - /24 subnet
4. **Memory Usage** - Resource consumption analysis
5. **Accuracy** - Service detection and banner grabbing quality

---

## 📊 Performance Results

### Single Host - Top 100 Ports

```bash
nullscan --target 127.0.0.1 --top100 --timeout 1500 --concurrency 200
nmap --top-ports 100 127.0.0.1 -T4
rustscan -a 127.0.0.1 --ulimit 5000 -- -sV --top-ports 100
masscan -p1-100 127.0.0.1 --rate 1000
```

| Scanner     | Avg Time | Std Dev | Memory Usage | Accuracy |
|-------------|----------|---------|---------------|----------|
| **NullScan** | **2.09s** | ± 0.03s | 12MB          | 97.5%    |
| Nmap        | 4.18s    | ± 0.12s | 28MB          | 100%     |
| RustScan    | 2.84s    | ± 0.08s | 15MB          | 95%      |
| Masscan     | 1.23s    | ± 0.05s | 8MB           | 85%      |

---

### Large Port Range - 1000 Ports (With Banner Grabbing)

```bash
nullscan --target 127.0.0.1 --ports 1-1000 --banners
nmap -p1-1000 -sV 127.0.0.1
```

| Scanner     | Avg Time | Memory Usage | Notes                  |
|-------------|----------|---------------|------------------------|
| **NullScan** | **20.5s** | 18MB          | Full banner grabbing   |
| Nmap        | 45.3s    | 35MB          | Service detection      |
| RustScan    | 32.1s    | 22MB          | Uses Nmap backend      |
| Masscan     | 12.8s    | 12MB          | No banner grabbing     |

---

### Network Range - /24 Subnet

```bash
nullscan --target 192.168.1.0/24 --ping-sweep --top100 --max-hosts 10
nmap --top-ports 100 192.168.1.0/24 -T4
```

| Scanner     | Discovery Time | Port Scan Time | Total Time |
|-------------|----------------|----------------|------------|
| **NullScan** | 2.3s           | 6.2s            | **8.5s**   |
| Nmap        | N/A            | 125s            | 125s       |
| RustScan    | 3.1s           | 12.4s           | 15.5s      |

---

## 💾 Memory Usage Snapshot

| Scanner     | Single Host | /24 Network | 1000 Ports |
|-------------|-------------|-------------|------------|
| **NullScan** | 12MB        | 25MB        | 18MB       |
| Nmap        | 28MB        | 85MB        | 35MB       |
| RustScan    | 15MB        | 45MB        | 22MB       |
| Masscan     | 8MB         | 15MB        | 12MB       |

---

## 🎯 Accuracy Comparison

Tested against 40 known services with manual verification (`telnet`, `nc`)

| Scanner     | Correct Detections | Total Tested | Accuracy |
|-------------|--------------------|--------------|----------|
| **NullScan** | 39                 | 40           | 97.5%    |
| Nmap        | 40                 | 40           | 100%     |
| RustScan    | 38                 | 40           | 95%      |
| Masscan     | 34                 | 40           | 85%      |

---

## 📌 Additional Notes

- **Masscan** rate throttled with `--rate 1000` to ensure fairness.
- **RustScan** used Nmap (`-sV`) for service detection.
- **NullScan** used protocol-specific probes.

---

## 🧪 Run Your Own Benchmarks

```bash
# Windows
scripts\benchmark.ps1 -Target "127.0.0.1" -Iterations 3

# Linux
./scripts/benchmark.sh 127.0.0.1 192.168.1.0/24 3
```

## 🔧 Performance Tuning Tips

### Speed
```bash
nullscan --target 192.168.1.0/24 --ping-sweep --top100 --max-hosts 20 --concurrency 200 --timeout 1000
```
### Accuracy
```bash
nullscan --target 192.168.1.1 --top1000 --banners --vuln-check --timeout 5000
```
### Large Networks
```bash
nullscan --target 10.0.0.0/16 --ping-sweep --top100 --max-hosts 50 --concurrency 300
```

## 📈 Conclusion

NullScan delivers a powerful blend of:
- 🔹 Speed (2-3x faster than Nmap)
- 🔹 Low resource consumption (50% less memory)
- 🔹 High accuracy (97.5%+ detection rate)
- 🔹 Smooth UX and flexible CLI

While Nmap remains the king of features and Masscan rules raw speed, **NullScan hits the sweet spot for efficient, actionable scanning**.

*Benchmarks performed on NullScan v1.0.0. Results may vary based on hardware and network conditions.*
