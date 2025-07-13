#!/usr/bin/env fish

# NullScan Usage Examples
# Demonstrate various features including ping sweep and parallel scanning
# For Fish shell users

# Set colors
set -l red (set_color red)
set -l green (set_color green)
set -l yellow (set_color yellow)
set -l blue (set_color blue)
set -l magenta (set_color magenta)
set -l cyan (set_color cyan)
set -l gray (set_color brblack)
set -l normal (set_color normal)

echo -e "$cyan🔍 NullScan Usage Examples$normal"
echo -e "$cyan=========================$normal"

# Build the project first
echo -e "\n$yellow📦 Building NullScan...$normal"
cargo build --release

if test $status -ne 0
    echo -e "$red❌ Build failed!$normal"
    exit 1
end

echo -e "\n$green✅ Build successful!$normal\n"

# Set up alias for easier usage
alias nullscan "./target/release/nullscan"
echo -e "$yellow🔧 Alias 'nullscan' created for this session!$normal"

echo -e "\n$cyan💡 Tip: To make this permanent, add this to your Fish config:$normal"
echo -e "$gray   echo \"alias nullscan '"(pwd)"/target/release/nullscan'\" >> ~/.config/fish/config.fish$normal"

function separator
    printf '=%.0s' (seq 80)
    echo
end

# Example 1: Basic scan
echo -e "\n$magenta🎯 Example 1: Basic scan of localhost with top 100 ports$normal"
echo -e "Command: nullscan --target 127.0.0.1 --top100"
./target/release/nullscan --target 127.0.0.1 --top100

echo -e "\n"(separator)

# Example 2: Network range scan (CIDR)
echo -e "\n$magenta🎯 Example 2: Network range scan with CIDR notation$normal"
echo -e "Command: nullscan --target 127.0.0.1/31 --ports 80,443 --verbose"
./target/release/nullscan --target 127.0.0.1/31 --ports 80,443 --verbose

echo -e "\n"(separator)

# Example 2.5: Ping sweep demonstration
echo -e "\n$magenta🎯 Example 2.5: Ping sweep for efficient network scanning$normal"
echo -e "Command: nullscan --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose"
echo -e "$gray(This will ping sweep first to find live hosts, then scan only reachable ones)$normal"
./target/release/nullscan --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose

echo -e "\n"(separator)

# Example 3: Multiple targets with ping sweep
echo -e "\n$magenta🎯 Example 3: Multiple targets with ping sweep$normal"
echo -e "Command: nullscan --target \"8.8.8.8,8.8.4.4,1.1.1.1\" --ping-sweep --ports 53,80,443"
./target/release/nullscan --target "8.8.8.8,8.8.4.4,1.1.1.1" --ping-sweep --ports 53,80,443

echo -e "\n"(separator)

# Example 4: Banner grabbing with JSON output
echo -e "\n$magenta🎯 Example 4: Scan with banner grabbing and JSON export$normal"
echo -e "Command: nullscan --target google.com --ports 80,443 --banners --format json --output google_scan.json"
./target/release/nullscan --target google.com --ports 80,443 --banners --format json --output google_scan.json

if test -f google_scan.json
    echo -e "\n$green📄 Generated JSON file:$normal"
    cat google_scan.json
end

echo -e "\n"(separator)

# Example 5: CSV export
echo -e "\n$magenta🎯 Example 5: Port range scan with CSV export$normal"
echo -e "Command: nullscan --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv"
./target/release/nullscan --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv

if test -f localhost_range.csv
    echo -e "\n$green📄 Generated CSV file:$normal"
    cat localhost_range.csv
end

echo -e "\n"(separator)

# Example 6: Performance comparison
echo -e "\n$magenta🎯 Example 6: Parallel vs Sequential Host Scanning$normal"

# Check if time command is available
if command -q time
    echo -e "Testing sequential scanning (--max-hosts 1):"
    echo -e "Command: time nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 1"
    time ./target/release/nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 1 >/dev/null 2>&1

    echo -e "\nTesting parallel scanning (--max-hosts 2):"
    echo -e "Command: time nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 2"
    time ./target/release/nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 2 >/dev/null 2>&1
else
    echo -e "Command: nullscan --target 127.0.0.1/30 --ports 80,443 --max-hosts 2 --verbose"
    ./target/release/nullscan --target 127.0.0.1/30 --ports 80,443 --max-hosts 2 --verbose
end

echo -e "\n$green🎉 Examples completed!$normal"
echo -e "$cyan📚 For more options, run: nullscan --help$normal"
echo -e "$cyan🌐 Advanced usage examples:$normal"
echo -e "$gray  - Large network with ping sweep: nullscan --target 10.0.0.0/24 --ping-sweep --top100 --max-hosts 10$normal"
echo -e "$gray  - Multiple targets: nullscan --target \"8.8.8.8,8.8.4.4,1.1.1.1\" --ping-sweep --ports 53,80,443$normal"
echo -e "$gray  - Enterprise scan: nullscan --target 172.16.0.0/16 --ping-sweep --top1000 --max-hosts 20 --format json$normal"
echo -e "$gray  - Parallel scanning: nullscan --target 192.168.1.0/24 --top100 --max-hosts 8$normal"

# Cleanup demo files
echo -e "\n$yellow🧹 Cleaning up demo files...$normal"
rm -f google_scan.json localhost_range.csv
echo -e "$green✅ Cleanup completed!$normal"

echo -e "\n$green Happy scanning! 🔍✨$normal"
