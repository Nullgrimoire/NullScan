#!/bin/bash

# NullScan Usage Examples
# Demonstrate various features including ping sweep and parallel scanning
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
NC='\033[0m' # No Color

echo -e "${CYAN}🔍 NullScan Usage Examples${NC}"
echo -e "${CYAN}=========================${NC}"

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

# Example 1: Basic scan
echo -e "\n${MAGENTA}🎯 Example 1: Basic scan of localhost with top 100 ports${NC}"
echo -e "Command: nullscan --target 127.0.0.1 --top100"
if [ "${CI_MODE:-0}" = "1" ]; then
    echo -e "${YELLOW}(CI Mode: Skipping actual scan, showing help instead)${NC}"
    ./target/release/nullscan --help | head -10
else
    ./target/release/nullscan --target 127.0.0.1 --top100
fi

echo -e "\n$(printf '=%.0s' {1..80})"

# Example 2: Network range scan (CIDR)
echo -e "\n${MAGENTA}🎯 Example 2: Network range scan with CIDR notation${NC}"
echo -e "Command: nullscan --target 127.0.0.1/31 --ports 80,443 --verbose"
if [ "${CI_MODE:-0}" = "1" ]; then
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
