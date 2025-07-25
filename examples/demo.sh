#!/bin/bash

# 🔍 NullScan Professional Demo Script
# Showcase all major features for content creators and cybersecurity professionals
# Demonstrates LUDICROUS SPEED, vulnerability assessment, and professional reporting
# For Linux, macOS, and other Unix-like systems

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔍 NullScan Professional Demo Suite${NC}"
echo -e "${CYAN}=====================================${NC}"
echo -e "${GRAY}Showcasing professional-grade network scanning capabilities${NC}"

# Check if running in CI mode
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "\n${YELLOW}🤖 Running in CI mode - limited functionality tests${NC}"
fi

# Build the project first
echo -e "\n${YELLOW}📦 Building NullScan...${NC}"
cargo build --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ Build successful!${NC}\n"

# Set up alias for easier usage (for current shell session)
alias nullscan="./target/release/nullscan"
echo -e "${YELLOW}🔧 Alias 'nullscan' created for this session!${NC}"

echo -e "\n${CYAN}💡 Tip: To make this permanent, add this to your shell profile:${NC}"
echo -e "${GRAY}   echo \"alias nullscan='$(pwd)/target/release/nullscan'\" >> ~/.bashrc${NC}"
echo -e "${GRAY}   # or for zsh: echo \"alias nullscan='$(pwd)/target/release/nullscan'\" >> ~/.zshrc${NC}"

# ==============================================================================
# DEMO 1: LUDICROUS SPEED Mode - The Performance Showcase
# ==============================================================================
echo -e "\n${MAGENTA}⚡ DEMO 1: LUDICROUS SPEED Mode - Maximum Performance${NC}"
echo -e "${MAGENTA}======================================================${NC}"
echo -e "Showcasing auto-optimized fast mode with CPU detection"
echo -e "Command: nullscan --target 127.0.0.1 --fast-mode --top100 --verbose"
echo ""
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "${YELLOW}(CI Mode: Showing fast mode capabilities)${NC}"
    echo "Fast Mode Features:"
    echo "• Auto CPU detection (cores × 150 concurrency)"
    echo "• 95ms timeout for rapid scanning"
    echo "• Batched processing for efficiency"
    echo "• Competitive with industry-standard tools"
else
    echo -e "${YELLOW}🚀 Watch the speed - auto-detects CPU cores and optimizes concurrency!${NC}"
    start_time=$(date +%s%3N)
    ./target/release/nullscan --target 127.0.0.1 --fast-mode --top100 --verbose
    end_time=$(date +%s%3N)
    duration=$((end_time - start_time))
    echo -e "\n${GREEN}⏱️  Fast Mode completed in: ${duration}ms${NC}"
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# ==============================================================================
# DEMO 2: Service Detection & Banner Grabbing
# ==============================================================================
echo -e "\n${MAGENTA}🔍 DEMO 2: Intelligent Service Detection${NC}"
echo -e "${MAGENTA}=========================================${NC}"
echo -e "Protocol-specific probes for accurate service identification"
echo -e "Command: nullscan --target 8.8.8.8 --ports 53,80,443 --banners --verbose"
echo ""
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "${YELLOW}(CI Mode: Showing banner grabbing capabilities)${NC}"
    echo "Service Detection Features:"
    echo "• SSH version handshake"
    echo "• HTTP/HTTPS server detection"
    echo "• Database protocol probing"
    echo "• Confidence scoring system"
else
    echo -e "${YELLOW}🎯 Watch intelligent protocol detection in action!${NC}"
    ./target/release/nullscan --target 8.8.8.8 --ports 53,80,443 --banners --verbose
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# ==============================================================================
# DEMO 3: Vulnerability Assessment
# ==============================================================================
echo -e "\n${MAGENTA}🛡️ DEMO 3: Offline Vulnerability Assessment${NC}"
echo -e "${MAGENTA}============================================${NC}"
echo -e "Real-time CVE detection with severity classification"
echo -e "Command: nullscan --target 127.0.0.1 --top100 --banners --vuln-check"
echo ""
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "${YELLOW}(CI Mode: Showing vulnerability features)${NC}"
    echo "Vulnerability Assessment Features:"
    echo "• Offline CVE database (12+ patterns)"
    echo "• CVSS severity scoring"
    echo "• Pattern matching for version detection"
    echo "• Real-time vulnerability display"
else
    echo -e "${YELLOW}🔒 Demonstrating integrated security assessment!${NC}"
    ./target/release/nullscan --target 127.0.0.1 --top100 --banners --vuln-check
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# ==============================================================================
# DEMO 4: Professional Reporting - HTML Export
# ==============================================================================
echo -e "\n${MAGENTA}📊 DEMO 4: Professional HTML Reports${NC}"
echo -e "${MAGENTA}====================================${NC}"
echo -e "Interactive HTML reports for penetration testing documentation"
echo -e "Command: nullscan --target 127.0.0.1 --top100 --banners --format html --output demo_report.html"
echo ""
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "${YELLOW}(CI Mode: Showing HTML report features)${NC}"
    echo "HTML Report Features:"
    echo "• Interactive sortable tables"
    echo "• Professional styling"
    echo "• Copy-to-clipboard functionality"
    echo "• Mobile-friendly responsive design"
    echo "• IP-grouped multi-host results"
else
    echo -e "${YELLOW}📝 Generating professional HTML report...${NC}"
    ./target/release/nullscan --target 127.0.0.1 --top100 --banners --format html --output demo_report.html
    if [ -f "demo_report.html" ]; then
        echo -e "${GREEN}✅ HTML report generated: demo_report.html${NC}"
        echo -e "${CYAN}   Open in browser to see interactive features!${NC}"
    fi
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# ==============================================================================
# DEMO 5: Network Range Scanning with Ping Sweep
# ==============================================================================
echo -e "\n${MAGENTA}� DEMO 5: Efficient Network Range Scanning${NC}"
echo -e "${MAGENTA}===========================================${NC}"
echo -e "115x faster than sequential scanning with ping sweep optimization"
echo -e "Command: nullscan --target 127.0.0.1/30 --ping-sweep --top100 --max-hosts 4 --verbose"
echo ""
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "${YELLOW}(CI Mode: Showing ping sweep benefits)${NC}"
    echo "Ping Sweep Optimization:"
    echo "• TCP-based host detection (not ICMP)"
    echo "• Parallel host discovery"
    echo "• Skip unreachable hosts"
    echo "• 115x performance improvement"
else
    echo -e "${YELLOW}🏓 Watch efficient network discovery in action!${NC}"
    start_time=$(date +%s%3N)
    ./target/release/nullscan --target 127.0.0.1/30 --ping-sweep --top100 --max-hosts 4 --verbose
    end_time=$(date +%s%3N)
    duration=$((end_time - start_time))
    echo -e "\n${GREEN}⏱️  Network scan completed in: ${duration}ms${NC}"
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# ==============================================================================
# DEMO 6: Multi-Format Export Showcase
# ==============================================================================
echo -e "\n${MAGENTA}📋 DEMO 6: Multi-Format Export Capabilities${NC}"
echo -e "${MAGENTA}============================================${NC}"
echo -e "Professional export formats for different use cases"
echo ""

formats=("json" "csv" "markdown")
for format in "${formats[@]}"; do
    echo -e "${YELLOW}Generating ${format} report...${NC}"
    output_file="demo_output.${format}"

    if [ "${CI_MODE:-0}" = "1" ]; then
        echo -e "${YELLOW}(CI Mode: Showing ${format} format capabilities)${NC}"
        case $format in
            "json") echo "• Machine-readable data exchange" ;;
            "csv") echo "• Spreadsheet compatibility" ;;
            "markdown") echo "• Documentation and reports" ;;
        esac
    else
        ./target/release/nullscan --target 127.0.0.1 --ports 80,443 --format "$format" --output "$output_file" --quiet
        if [ -f "$output_file" ]; then
            echo -e "${GREEN}✅ Generated: ${output_file}${NC}"
        fi
    fi
done

echo -e "\n$(printf '=%.0s' {1..80})"

# ==============================================================================
# DEMO SUMMARY & NEXT STEPS
# ==============================================================================
echo -e "\n${CYAN}🎯 Demo Summary - NullScan Professional Features${NC}"
echo -e "${CYAN}=================================================${NC}"
echo ""
echo -e "${GREEN}✅ LUDICROUS SPEED Mode - Auto CPU optimization${NC}"
echo -e "${GREEN}✅ Service Detection - Protocol-specific probing${NC}"
echo -e "${GREEN}✅ Vulnerability Assessment - Offline CVE database${NC}"
echo -e "${GREEN}✅ Professional Reports - Interactive HTML output${NC}"
echo -e "${GREEN}✅ Network Optimization - 115x faster ping sweep${NC}"
echo -e "${GREEN}✅ Multi-Format Export - JSON, CSV, HTML, Markdown${NC}"
echo ""
echo -e "${YELLOW}🚀 Ready for:${NC}"
echo -e "${WHITE}   • Penetration Testing${NC}"
echo -e "${WHITE}   • Network Administration${NC}"
echo -e "${WHITE}   • Security Assessments${NC}"
echo -e "${WHITE}   • Automation & CI/CD${NC}"
echo ""
echo -e "${CYAN}📚 For detailed documentation:${NC}"
echo -e "${GRAY}   • Performance Benchmarks: docs/benchmarks.md${NC}"
echo -e "${GRAY}   • Fast Mode Guide: docs/fast-mode-deep-dive.md${NC}"
echo -e "${GRAY}   • Banner Grabbing: docs/banner-grabbing-deep-dive.md${NC}"
echo ""
echo -e "${MAGENTA}🎬 Content Creator Ready!${NC}"
echo -e "${WHITE}   Professional-grade tool with competitive performance${NC}"

echo -e "\n$(printf '=%.0s' {1..80})"

echo -e "\n${GREEN}🎉 Professional demo completed!${NC}"
echo -e "${CYAN}📚 For more options, run: ./target/release/nullscan --help${NC}"
echo -e "${CYAN}🌐 Network range scanning examples:${NC}"
echo -e "${GRAY}  - Local subnet: ./target/release/nullscan --target 192.168.1.0/24 --top100${NC}"
echo -e "${GRAY}  - Fast discovery: ./target/release/nullscan --target 10.0.0.0/24 --ping-sweep --fast-mode --top100${NC}"
echo -e "${GRAY}  - Security audit: ./target/release/nullscan --target target.com --top1000 --banners --vuln-check --format html${NC}"
    echo -e "${YELLOW}(CI Mode: Showing version instead)${NC}"
    ./target/release/nullscan --version
else
    ./target/release/nullscan --target 127.0.0.1/31 --ports 80,443 --verbose
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# Example 2.5: Ping sweep demonstration
echo -e "\n${MAGENTA}🎯 Example 2.5: Ping sweep for efficient network scanning${NC}"
echo -e "Command: nullscan --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose"
echo -e "(This will ping sweep first to find live hosts, then scan only reachable ones)"
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "${YELLOW}(CI Mode: Showing ping sweep feature info)${NC}"
    ./target/release/nullscan --help | grep -i ping -A 2 -B 2 || echo "Ping sweep optimizes scanning by testing host availability first"
else
    ./target/release/nullscan --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# Example 3: Multiple targets with ping sweep
echo -e "\n${MAGENTA}🎯 Example 3: Multiple targets with ping sweep${NC}"
echo -e "Command: nullscan --target \"8.8.8.8,8.8.4.4,1.1.1.1\" --ping-sweep --ports 53,80,443"
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "${YELLOW}(CI Mode: Showing multiple target syntax)${NC}"
    echo "Multiple targets can be specified as: --target \"host1,host2,host3\""
    ./target/release/nullscan --help | grep -i target -A 1 || echo "Multiple targets supported"
else
    ./target/release/nullscan --target "8.8.8.8,8.8.4.4,1.1.1.1" --ping-sweep --ports 53,80,443
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# Example 4: Banner grabbing with JSON output
echo -e "\n${MAGENTA}🎯 Example 4: Scan with banner grabbing and JSON export${NC}"
echo -e "Command: nullscan --target google.com --ports 80,443 --banners --format json --output google_scan.json"
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "${YELLOW}(CI Mode: Showing JSON format example)${NC}"
    echo '{"target":"example.com","ports":[{"port":80,"state":"open","service":"http","banner":"Server: nginx/1.18.0"}]}'
    touch google_scan.json
    echo '{"target":"example.com","ports":[{"port":80,"state":"open","service":"http","banner":"Server: nginx/1.18.0"}]}' > google_scan.json
else
    ./target/release/nullscan --target google.com --ports 80,443 --banners --format json --output google_scan.json
fi

if [ -f "google_scan.json" ]; then
    echo -e "\n${GREEN}📄 Generated JSON file:${NC}"
    cat google_scan.json
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# Example 5: CSV export
echo -e "\n${MAGENTA}🎯 Example 5: Port range scan with CSV export${NC}"
echo -e "Command: nullscan --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv"
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "${YELLOW}(CI Mode: Showing CSV format example)${NC}"
    echo "host,port,state,service,banner"
    echo "127.0.0.1,135,closed,msrpc,"
    echo "127.0.0.1,139,closed,netbios-ssn,"
    touch localhost_range.csv
    echo "host,port,state,service,banner" > localhost_range.csv
    echo "127.0.0.1,135,closed,msrpc," >> localhost_range.csv
    echo "127.0.0.1,139,closed,netbios-ssn," >> localhost_range.csv
else
    ./target/release/nullscan --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv
fi

if [ -f "localhost_range.csv" ]; then
    echo -e "\n${GREEN}📄 Generated CSV file:${NC}"
    cat localhost_range.csv
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# Example 6: Performance comparison (if we have time command)
if command -v time &> /dev/null; then
    echo -e "\n${MAGENTA}🎯 Example 6: Parallel vs Sequential Host Scanning${NC}"
    if [ "${CI_MODE:-0}" = "1" ]; then
        echo -e "${YELLOW}(CI Mode: Showing performance comparison concept)${NC}"
        echo "Sequential scanning (--max-hosts 1): One host at a time"
        echo "Parallel scanning (--max-hosts 2+): Multiple hosts simultaneously"
        echo "Performance benefits scale with network size and available resources"
    else
        echo -e "Testing sequential scanning (--max-hosts 1):"
        echo -e "Command: time nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 1"
        time ./target/release/nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 1 > /dev/null 2>&1

        echo -e "\nTesting parallel scanning (--max-hosts 2):"
        echo -e "Command: time nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 2"
        time ./target/release/nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 2 > /dev/null 2>&1
    fi
else
    echo -e "\n${MAGENTA}🎯 Example 6: Parallel host scanning${NC}"
    echo -e "Command: nullscan --target 127.0.0.1/30 --ports 80,443 --max-hosts 2 --verbose"
    if [ "${CI_MODE:-0}" = "1" ]; then
        echo -e "${YELLOW}(CI Mode: Showing parallel scanning info)${NC}"
        ./target/release/nullscan --help | grep -i max-hosts -A 2 -B 2 || echo "max-hosts controls parallel scanning capacity"
    else
        ./target/release/nullscan --target 127.0.0.1/30 --ports 80,443 --max-hosts 2 --verbose
    fi
fi

echo -e "\n${GREEN}🎉 Examples completed!${NC}"
echo -e "${CYAN}📚 For more options, run: nullscan --help${NC}"
echo -e "${CYAN}🌐 Advanced usage examples:${NC}"
echo -e "${GRAY}  - Large network with ping sweep: nullscan --target 10.0.0.0/24 --ping-sweep --top100 --max-hosts 10${NC}"
echo -e "${GRAY}  - Multiple targets: nullscan --target \"8.8.8.8,8.8.4.4,1.1.1.1\" --ping-sweep --ports 53,80,443${NC}"
echo -e "${GRAY}  - Enterprise scan: nullscan --target 172.16.0.0/16 --ping-sweep --top1000 --max-hosts 20 --format json${NC}"
echo -e "${GRAY}  - Parallel scanning: nullscan --target 192.168.1.0/24 --top100 --max-hosts 8${NC}"

# Cleanup demo files
echo -e "\n${YELLOW}🧹 Cleaning up demo files...${NC}"
rm -f google_scan.json localhost_range.csv
echo -e "${GREEN}✅ Cleanup completed!${NC}"

echo -e "\n${GREEN}Happy scanning! 🔍✨${NC}"
