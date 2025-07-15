#!/bin/bash

# NullScan Simple Benchmark Script
# Quick performance testing for NullScan
# Usage: ./benchmark.sh [target] [iterations]

# Configuration
TARGET="${1:-127.0.0.1}"
ITERATIONS="${2:-3}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building NullScan...${NC}"
cargo build --release
if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

NULLSCAN="./target/release/nullscan"

echo -e "${YELLOW}Verifying NullScan...${NC}"
$NULLSCAN --version > /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}NullScan verification failed!${NC}"
    exit 1
fi

echo -e "\n${GREEN}Starting benchmark tests on $TARGET...${NC}"
echo -e "${BLUE}Running $ITERATIONS iterations per test${NC}\n"

# Test 1: Top 100 ports
echo -e "${CYAN}Test 1: Top 100 ports scan${NC}"
TIMES1=()
for i in $(seq 1 $ITERATIONS); do
    echo -n "  Run $i/$ITERATIONS... "
    START=$(date +%s.%N)
    $NULLSCAN --target $TARGET --top100 --quiet > /dev/null 2>&1
    END=$(date +%s.%N)
    DURATION=$(echo "$END - $START" | bc -l)
    TIMES1+=($DURATION)
    printf "${GREEN}%.2fs${NC}\n" $DURATION
done

# Calculate average for test 1
AVG1=0
for time in "${TIMES1[@]}"; do
    AVG1=$(echo "$AVG1 + $time" | bc -l)
done
AVG1=$(echo "scale=2; $AVG1 / $ITERATIONS" | bc -l)
echo -e "  ${YELLOW}Average: ${AVG1}s${NC}"

# Test 2: Common ports with banners
echo -e "\n${CYAN}Test 2: Common ports with banners${NC}"
TIMES2=()
for i in $(seq 1 $ITERATIONS); do
    echo -n "  Run $i/$ITERATIONS... "
    START=$(date +%s.%N)
    $NULLSCAN --target $TARGET --ports 22,80,443,3389 --banners --quiet > /dev/null 2>&1
    END=$(date +%s.%N)
    DURATION=$(echo "$END - $START" | bc -l)
    TIMES2+=($DURATION)
    printf "${GREEN}%.2fs${NC}\n" $DURATION
done

# Calculate average for test 2
AVG2=0
for time in "${TIMES2[@]}"; do
    AVG2=$(echo "$AVG2 + $time" | bc -l)
done
AVG2=$(echo "scale=2; $AVG2 / $ITERATIONS" | bc -l)
echo -e "  ${YELLOW}Average: ${AVG2}s${NC}"

# Test 3: Fast mode
echo -e "\n${CYAN}Test 3: Fast mode scan${NC}"
TIMES3=()
for i in $(seq 1 $ITERATIONS); do
    echo -n "  Run $i/$ITERATIONS... "
    START=$(date +%s.%N)
    $NULLSCAN --target $TARGET --fast-mode --top100 --quiet > /dev/null 2>&1
    END=$(date +%s.%N)
    DURATION=$(echo "$END - $START" | bc -l)
    TIMES3+=($DURATION)
    printf "${GREEN}%.2fs${NC}\n" $DURATION
done

# Calculate average for test 3
AVG3=0
for time in "${TIMES3[@]}"; do
    AVG3=$(echo "$AVG3 + $time" | bc -l)
done
AVG3=$(echo "scale=2; $AVG3 / $ITERATIONS" | bc -l)
echo -e "  ${YELLOW}Average: ${AVG3}s${NC}"

# Results summary
echo -e "\n${CYAN}==================================================${NC}"
echo -e "${GREEN}BENCHMARK RESULTS${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "Target: $TARGET"
echo -e "Iterations per test: $ITERATIONS"
echo ""
echo -e "Test 1 - Top 100 ports:       ${AVG1}s"
echo -e "Test 2 - Common ports+banners: ${AVG2}s"
echo -e "Test 3 - Fast mode:           ${AVG3}s"
echo ""

# Find fastest test
FASTEST_TIME=$AVG1
FASTEST_NAME="Top 100 ports"
if (( $(echo "$AVG2 < $FASTEST_TIME" | bc -l) )); then
    FASTEST_TIME=$AVG2
    FASTEST_NAME="Common ports+banners"
fi
if (( $(echo "$AVG3 < $FASTEST_TIME" | bc -l) )); then
    FASTEST_TIME=$AVG3
    FASTEST_NAME="Fast mode"
fi

echo -e "${GREEN}Fastest test: $FASTEST_NAME (${FASTEST_TIME}s)${NC}"

# Save results to CSV
CSV_FILE="benchmark_results_$(date +%Y%m%d_%H%M%S).csv"
echo "Test,AverageTime,AllTimes" > $CSV_FILE
echo "Top100,$AVG1,\"$(IFS=';'; echo "${TIMES1[*]}")\"" >> $CSV_FILE
echo "CommonPorts,$AVG2,\"$(IFS=';'; echo "${TIMES2[*]}")\"" >> $CSV_FILE
echo "FastMode,$AVG3,\"$(IFS=';'; echo "${TIMES3[*]}")\"" >> $CSV_FILE

echo -e "${BLUE}Results saved to: $CSV_FILE${NC}"
echo -e "${GREEN}Benchmark complete!${NC}"
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# System information gathering
get_system_info() {
    echo -e "${BLUE}System Information:${NC}"
    echo "CPU: $(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | xargs)"
    echo "Cores: $(nproc)"
    echo "RAM: $(free -h | grep '^Mem:' | awk '{print $2}')"
    echo "OS: $(uname -sr)"
    echo "Kernel: $(uname -r)"
}

# Performance measurement function
measure_performance() {
    local scanner_name="$1"
    local command="$2"
    local test_name="$3"
    local target="$4"
    local iterations="$5"

    print_section "Testing $scanner_name - $test_name"
    echo -e "${BLUE}Command: $command${NC}"
    echo -e "${BLUE}Iterations: $iterations${NC}"

    local times=()
    local success=true
    local error_msg=""

    for ((i=1; i<=iterations; i++)); do
        echo -n "  Run $i/$iterations... "

        local start_time=$(date +%s.%N)

        if timeout 30 bash -c "$command" >/dev/null 2>&1; then
            local end_time=$(date +%s.%N)
            local duration=$(echo "$end_time - $start_time" | bc -l)
            times+=($duration)
            echo -e "${GREEN}$(printf "%.3f" $duration)s${NC}"
        else
            local exit_code=$?
            echo -e "${RED}FAILED${NC}"
            success=false
            error_msg="Exit code: $exit_code"
            break
        fi

        sleep 0.5
    done

    if [ "$success" = true ] && [ ${#times[@]} -gt 0 ]; then
        # Calculate statistics
        local sum=0
        local min=${times[0]}
        local max=${times[0]}

        for time in "${times[@]}"; do
            sum=$(echo "$sum + $time" | bc -l)
            if (( $(echo "$time < $min" | bc -l) )); then
                min=$time
            fi
            if (( $(echo "$time > $max" | bc -l) )); then
                max=$time
            fi
        done

        local avg=$(echo "scale=3; $sum / ${#times[@]}" | bc -l)

        # Calculate standard deviation
        local variance_sum=0
        for time in "${times[@]}"; do
            local diff=$(echo "$time - $avg" | bc -l)
            local sq_diff=$(echo "$diff * $diff" | bc -l)
            variance_sum=$(echo "$variance_sum + $sq_diff" | bc -l)
        done
        local variance=$(echo "scale=6; $variance_sum / ${#times[@]}" | bc -l)
        local stddev=$(echo "scale=3; sqrt($variance)" | bc -l)

        printf "  Results: Avg=%.3fs, Min=%.3fs, Max=%.3fs, StdDev=%.3fs\n" \
               $(printf "%.3f" $avg) $(printf "%.3f" $min) $(printf "%.3f" $max) $(printf "%.3f" $stddev)

        # Store result
        local all_times=$(IFS=';'; echo "${times[*]}")
        echo "$scanner_name,$test_name,$target,$(printf "%.3f" $avg),$(printf "%.3f" $min),$(printf "%.3f" $max),$(printf "%.3f" $stddev),true,,$command" >> "$RESULTS_FILE"
    else
        echo "$scanner_name,$test_name,$target,,,,,false,$error_msg,$command" >> "$RESULTS_FILE"
    fi
}

# Generate HTML report
generate_html_report() {
    local report_file="benchmark_report_$(date +%Y%m%d_%H%M%S).html"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>NullScan Benchmark Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; text-align: center; }
        .system-info { background: white; padding: 15px; margin: 20px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .benchmark-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .benchmark-table th { background-color: #4CAF50; color: white; padding: 12px; text-align: left; }
        .benchmark-table td { padding: 12px; border-bottom: 1px solid #ddd; }
        .benchmark-table tr:hover { background-color: #f5f5f5; }
        .success { color: #4CAF50; font-weight: bold; }
        .error { color: #f44336; font-weight: bold; }
        .stats { display: flex; justify-content: space-around; margin: 20px 0; }
        .stat-box { background: white; padding: 20px; border-radius: 8px; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .footer { text-align: center; margin: 20px 0; color: #666; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 NullScan Benchmark Report</h1>
        <p>Generated on $timestamp</p>
    </div>

    <div class="system-info">
        <h3>System Information</h3>
        <p><strong>CPU:</strong> $(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | xargs)</p>
        <p><strong>Cores:</strong> $(nproc)</p>
        <p><strong>RAM:</strong> $(free -h | grep '^Mem:' | awk '{print $2}')</p>
        <p><strong>OS:</strong> $(uname -sr)</p>
    </div>

    <table class="benchmark-table">
        <thead>
            <tr>
                <th>Scanner</th>
                <th>Test</th>
                <th>Target</th>
                <th>Avg Time (s)</th>
                <th>Min Time (s)</th>
                <th>Max Time (s)</th>
                <th>Std Dev</th>
                <th>Status</th>
                <th>Command</th>
            </tr>
        </thead>
        <tbody>
EOF

    # Add table rows from CSV
    tail -n +2 "$RESULTS_FILE" | while IFS=',' read -r scanner test target avg min max stddev success error command; do
        local status_class="success"
        local status_text="✅ Success"

        if [ "$success" != "true" ]; then
            status_class="error"
            status_text="❌ $error"
        fi

        cat >> "$report_file" << EOF
            <tr>
                <td><strong>$scanner</strong></td>
                <td>$test</td>
                <td>$target</td>
                <td>$avg</td>
                <td>$min</td>
                <td>$max</td>
                <td>$stddev</td>
                <td class="$status_class">$status_text</td>
                <td><code>$command</code></td>
            </tr>
EOF
    done

    cat >> "$report_file" << EOF
        </tbody>
    </table>

    <div class="footer">
        <p>Generated by NullScan Benchmark Suite v2.0</p>
        <p>🚀 Built with ❤️ for performance testing</p>
    </div>
</body>
</html>
EOF

    print_success "HTML report saved to: $report_file"
}

# Main execution
main() {
    print_banner "NullScan Professional Benchmark Suite v2.0"

    # System information
    print_section "System Information"
    get_system_info

    # Check dependencies
    print_section "Checking Dependencies"

    if ! command -v cargo &> /dev/null; then
        print_error "Cargo not found. Please install Rust."
        exit 1
    fi

    if ! command -v bc &> /dev/null; then
        print_error "bc (calculator) not found. Please install bc package."
        exit 1
    fi

    # Build NullScan
    print_section "Building NullScan"
    if cargo build --release; then
        print_success "Build successful"
    else
        print_error "Build failed"
        exit 1
    fi

    NULLSCAN_PATH="./target/release/nullscan"

    # Verify NullScan works
    print_section "Verifying NullScan"
    if "$NULLSCAN_PATH" --version >/dev/null 2>&1; then
        print_success "NullScan verified"
    else
        print_error "NullScan verification failed"
        exit 1
    fi

    # Check for external scanners
    nmap_available=false
    if [ "$SKIP_NMAP" != "true" ] && [ "$ONLY_NULLSCAN" != "true" ]; then
        if command -v nmap &> /dev/null; then
            nmap_available=true
            print_success "Nmap detected"
        else
            print_warning "Nmap not available, skipping comparisons"
        fi
    fi

    # Initialize results file
    echo "Scanner,Test,Target,AvgTime,MinTime,MaxTime,StdDev,Success,Error,Command" > "$RESULTS_FILE"

    print_banner "Performance Tests"

    # Test 1: Single host, top 100 ports
    measure_performance "NullScan" "$NULLSCAN_PATH --target $TARGET --top100 --quiet" "Top 100 Ports" "$TARGET" "$ITERATIONS"

    if [ "$nmap_available" = true ]; then
        measure_performance "Nmap" "nmap --top-ports 100 $TARGET" "Top 100 Ports" "$TARGET" "$ITERATIONS"
    fi

    # Test 2: Single host, specific ports
    measure_performance "NullScan" "$NULLSCAN_PATH --target $TARGET --ports 22,80,443,3389 --quiet" "Common Ports" "$TARGET" "$ITERATIONS"

    if [ "$nmap_available" = true ]; then
        measure_performance "Nmap" "nmap -p 22,80,443,3389 $TARGET" "Common Ports" "$TARGET" "$ITERATIONS"
    fi

    # Test 3: Fast mode
    measure_performance "NullScan" "$NULLSCAN_PATH --target $TARGET --fast-mode --top100" "Fast Mode" "$TARGET" "$ITERATIONS"

    # Test 4: With banners
    measure_performance "NullScan" "$NULLSCAN_PATH --target $TARGET --ports 22,80,443 --banners --quiet" "With Banners" "$TARGET" "$ITERATIONS"

    if [ "$nmap_available" = true ]; then
        measure_performance "Nmap" "nmap -sV -p 22,80,443 $TARGET" "With Service Detection" "$TARGET" "$ITERATIONS"
    fi

    # Test 5: Network range (if not skipped)
    if [ "$SKIP_NETWORK" != "true" ]; then
        print_section "Network Range Tests"
        print_info "Target: $NETWORK_TARGET"

        measure_performance "NullScan" "$NULLSCAN_PATH --target $NETWORK_TARGET --ping-sweep --top100 --quiet" "Network Ping Sweep" "$NETWORK_TARGET" "$NETWORK_ITERATIONS"

        if [ "$nmap_available" = true ]; then
            measure_performance "Nmap" "nmap --top-ports 100 $NETWORK_TARGET" "Network Scan" "$NETWORK_TARGET" "$NETWORK_ITERATIONS"
        fi
    fi

    # Results summary
    print_banner "Benchmark Results Summary"

    local total_tests=$(tail -n +2 "$RESULTS_FILE" | wc -l)
    local successful_tests=$(tail -n +2 "$RESULTS_FILE" | grep ",true," | wc -l)
    local failed_tests=$((total_tests - successful_tests))

    print_success "Successful Tests: $successful_tests"
    if [ $failed_tests -gt 0 ]; then
        print_error "Failed Tests: $failed_tests"
    fi

    if [ $successful_tests -gt 0 ]; then
        echo -e "\n${CYAN}Performance Summary:${NC}"

        tail -n +2 "$RESULTS_FILE" | grep ",true," | while IFS=',' read -r scanner test target avg min max stddev success error command; do
            if (( $(echo "$avg < 1" | bc -l) )); then
                status="🚀"
            elif (( $(echo "$avg < 5" | bc -l) )); then
                status="⚡"
            else
                status="🐌"
            fi
            echo "$status $scanner - $test: ${avg}s avg"
        done
    fi

    # Export results
    if [ -n "$OUTPUT_FILE" ]; then
        cp "$RESULTS_FILE" "$OUTPUT_FILE"
        print_success "Results exported to: $OUTPUT_FILE"
    fi

    # Generate HTML report
    if [ "$GENERATE_REPORT" = "true" ]; then
        generate_html_report
    fi

    print_banner "Benchmark Complete"
    print_success "🎉 All tests completed successfully!"
    print_info "Results saved to: $RESULTS_FILE"
}

# Help function
show_help() {
    cat << EOF
NullScan Professional Benchmark Suite v2.0

Usage: $0 [TARGET] [NETWORK_TARGET] [ITERATIONS] [NETWORK_ITERATIONS] [SKIP_NMAP] [SKIP_NETWORK] [ONLY_NULLSCAN] [OUTPUT_FILE] [GENERATE_REPORT]

Parameters:
  TARGET              Target IP or hostname (default: 127.0.0.1)
  NETWORK_TARGET      Network range for testing (default: 192.168.1.0/24)
  ITERATIONS          Number of iterations for single host tests (default: 5)
  NETWORK_ITERATIONS  Number of iterations for network tests (default: 3)
  SKIP_NMAP          Skip nmap comparisons (true/false, default: false)
  SKIP_NETWORK       Skip network range tests (true/false, default: false)
  ONLY_NULLSCAN      Only test NullScan (true/false, default: false)
  OUTPUT_FILE        Custom output CSV file path
  GENERATE_REPORT    Generate HTML report (true/false, default: false)

Examples:
  $0                                          # Basic localhost test
  $0 127.0.0.1 192.168.1.0/24 10 3 false     # Custom parameters
  $0 127.0.0.1 "" 5 3 true true false        # Skip nmap and network tests
  $0 "" "" "" "" "" "" true results.csv true # Only NullScan with custom output

EOF
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Execute main function
main

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

    measure_performance "NullScan" "$NULLSCAN_PATH --target $NETWORK_TARGET --top100 --ping-sweep --ping-timeout 500 --max-hosts 30 --concurrency 300" "Network Range"

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
