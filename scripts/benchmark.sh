#!/bin/bash

# NullScan Performance Benchmark Script
# Compares NullScan against other popular TCP scanners

set -e

# Configuration
TARGET="${1:-127.0.0.1}"
NETWORK_TARGET="${2:-192.168.1.0/24}"
ITERATIONS="${3:-3}"
SKIP_EXTERNAL="${4:-false}"

echo "🔍 NullScan Performance Benchmark"
echo "==================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Build NullScan
echo -e "\n${YELLOW}🔨 Building NullScan...${NC}"
cargo build --release

NULLSCAN_PATH="./target/release/nullscan"

# Test NullScan
echo -e "${GREEN}✅ Testing NullScan...${NC}"
timeout 10 "$NULLSCAN_PATH" --target "$TARGET" --ports 80 --timeout 1000 > /dev/null || {
    echo -e "${RED}❌ NullScan test failed${NC}"
    exit 1
}

# Results storage
RESULTS_FILE="benchmark_results_$(date +%Y%m%d_%H%M%S).csv"
echo "Scanner,Test,AverageTime,MinTime,MaxTime,AllTimes" > "$RESULTS_FILE"

# Function to measure performance
measure_performance() {
    local scanner_name="$1"
    local command="$2"
    local test_name="$3"

    echo -e "\n${BLUE}🚀 Testing $scanner_name - $test_name${NC}"

    local times=()
    local total_time=0

    for ((i=1; i<=ITERATIONS; i++)); do
        echo -n "  Run $i/$ITERATIONS..."

        if start_time=$(date +%s.%N); then
            if timeout 300 bash -c "$command" > /dev/null 2>&1; then
                end_time=$(date +%s.%N)
                duration=$(echo "$end_time - $start_time" | bc -l)
                times+=("$duration")
                total_time=$(echo "$total_time + $duration" | bc -l)
                printf " ${GREEN}%.2fs${NC}\n" "$duration"
            else
                echo -e " ${RED}FAILED${NC}"
                return 1
            fi
        fi
    done

    # Calculate statistics
    local avg_time=$(echo "scale=2; $total_time / $ITERATIONS" | bc -l)
    local min_time=$(printf '%s\n' "${times[@]}" | sort -n | head -1)
    local max_time=$(printf '%s\n' "${times[@]}" | sort -n | tail -1)
    local all_times=$(IFS=';'; echo "${times[*]}")

    # Save to CSV
    echo "$scanner_name,$test_name,$avg_time,$min_time,$max_time,$all_times" >> "$RESULTS_FILE"

    printf "📊 %s: Avg=%.2fs, Min=%.2fs, Max=%.2fs\n" "$scanner_name" "$avg_time" "$min_time" "$max_time"
}

# Check for external scanners
check_scanner() {
    if command -v "$1" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Found $1${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  $1 not found - skipping $1 benchmarks${NC}"
        return 1
    fi
}

# Test 1: Single Host - Top 100 Ports
echo -e "\n${MAGENTA}📊 Benchmark 1: Single Host Top 100 Ports ($TARGET)${NC}"

measure_performance "NullScan" "$NULLSCAN_PATH --target $TARGET --top100" "Single Host Top 100"

if [ "$SKIP_EXTERNAL" != "true" ]; then
    if check_scanner "nmap"; then
        measure_performance "Nmap" "nmap --top-ports 100 $TARGET" "Single Host Top 100"
    fi

    if check_scanner "masscan"; then
        measure_performance "Masscan" "masscan -p1-100 $TARGET --rate 1000" "Single Host Top 100"
    fi

    if check_scanner "rustscan"; then
        measure_performance "RustScan" "rustscan -a $TARGET -- -sV --top-ports 100" "Single Host Top 100"
    fi
fi

# Test 2: Large Port Range
echo -e "\n${MAGENTA}📊 Benchmark 2: Large Port Range ($TARGET ports 1-1000)${NC}"

measure_performance "NullScan" "$NULLSCAN_PATH --target $TARGET --ports 1-1000" "Large Port Range"

if [ "$SKIP_EXTERNAL" != "true" ]; then
    if command -v nmap > /dev/null 2>&1; then
        measure_performance "Nmap" "nmap -p1-1000 $TARGET" "Large Port Range"
    fi

    if command -v masscan > /dev/null 2>&1; then
        measure_performance "Masscan" "masscan -p1-1000 $TARGET --rate 1000" "Large Port Range"
    fi
fi

# Test 3: Network Range (if not localhost)
if [ "$TARGET" != "127.0.0.1" ] && [ "$NETWORK_TARGET" != "127.0.0.1/32" ]; then
    echo -e "\n${MAGENTA}📊 Benchmark 3: Network Range ($NETWORK_TARGET)${NC}"

    measure_performance "NullScan" "$NULLSCAN_PATH --target $NETWORK_TARGET --top100 --max-hosts 5" "Network Range"

    if [ "$SKIP_EXTERNAL" != "true" ] && command -v nmap > /dev/null 2>&1; then
        measure_performance "Nmap" "nmap --top-ports 100 $NETWORK_TARGET" "Network Range"
    fi
fi

# Generate report
echo -e "\n${GREEN}🏆 BENCHMARK RESULTS${NC}"
echo "===================="

if [ ! -s "$RESULTS_FILE" ] || [ "$(wc -l < "$RESULTS_FILE")" -le 1 ]; then
    echo -e "${RED}No benchmark results to display${NC}"
    exit 1
fi

# Process results with awk for better formatting
awk -F',' '
BEGIN {
    print ""
}
NR>1 {
    if ($2 != prev_test) {
        if (prev_test != "") print ""
        printf "\033[0;36m📊 %s:\033[0m\n", $2
        printf "%s\n", "─────────────────────────────────────────────"
        prev_test = $2
    }

    scanner = $1
    avg = $3
    min = $4
    max = $5

    printf "%-15s | Avg: %8.2fs | Min: %8.2fs | Max: %8.2fs\n", scanner, avg, min, max
}' "$RESULTS_FILE"

echo -e "\n${BLUE}📄 Detailed results saved to: $RESULTS_FILE${NC}"

# Performance tips
echo -e "\n${CYAN}💡 Performance Tips:${NC}"
echo "• Use --ping-sweep for network ranges to skip dead hosts"
echo "• Increase --max-hosts for faster network scanning"
echo "• Adjust --concurrency based on your system capabilities"
echo "• Use --timeout to control scan speed vs accuracy"

echo -e "\n${GREEN}✅ Benchmark complete!${NC}"
