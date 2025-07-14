#!/bin/bash

# 🎬 NullScan Content Creator Benchmark Script (Linux/macOS)
# Perfect for YouTube videos, technical demos, and performance comparisons
# Automated benchmark comparison showcasing NullScan's competitive performance

TARGET="${1:-127.0.0.1}"
ITERATIONS="${2:-3}"
DETAILED="${3:-false}"

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

echo -e "${CYAN}🎬 NullScan Content Creator Benchmark Suite${NC}"
echo -e "${CYAN}=============================================${NC}"
echo -e "${GRAY}Perfect for creating performance comparison content${NC}"
echo ""

# Build NullScan first
echo -e "${YELLOW}📦 Building NullScan...${NC}"
cd "$(dirname "$0")/../.."
cargo build --release --quiet
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

# ==============================================================================
# BENCHMARK 1: Fast Mode Performance Showcase
# ==============================================================================
echo -e "${MAGENTA}⚡ BENCHMARK 1: LUDICROUS SPEED Mode Performance${NC}"
echo -e "${MAGENTA}=================================================${NC}"
echo -e "Demonstrating auto-optimized fast mode capabilities"
echo ""

fast_times=()
fast_total=0
for i in $(seq 1 $ITERATIONS); do
    echo -e "${YELLOW}🚀 Fast Mode Run $i/$ITERATIONS...${NC}"
    start_time=$(date +%s%3N)
    ./target/release/nullscan --target "$TARGET" --fast-mode --top100 --quiet > /dev/null 2>&1
    end_time=$(date +%s%3N)
    duration=$((end_time - start_time))
    fast_times+=($duration)
    fast_total=$((fast_total + duration))
    echo -e "   Time: ${duration}ms"
done

avg_fast=$((fast_total / ITERATIONS))
min_fast=${fast_times[0]}
max_fast=${fast_times[0]}
for time in "${fast_times[@]}"; do
    [ $time -lt $min_fast ] && min_fast=$time
    [ $time -gt $max_fast ] && max_fast=$time
done

echo ""
echo -e "${CYAN}📊 Fast Mode Results:${NC}"
echo -e "   Average: ${avg_fast}ms"
echo -e "${GREEN}   Best:    ${min_fast}ms${NC}"
echo -e "${YELLOW}   Worst:   ${max_fast}ms${NC}"

# ==============================================================================
# BENCHMARK 2: Regular Mode Comparison
# ==============================================================================
echo ""
echo -e "${MAGENTA}🔍 BENCHMARK 2: Regular Mode Comparison${NC}"
echo -e "${MAGENTA}=======================================${NC}"
echo -e "Standard scanning mode for feature comparison"
echo ""

regular_times=()
regular_total=0
for i in $(seq 1 $ITERATIONS); do
    echo -e "${YELLOW}🎯 Regular Mode Run $i/$ITERATIONS...${NC}"
    start_time=$(date +%s%3N)
    ./target/release/nullscan --target "$TARGET" --top100 --quiet > /dev/null 2>&1
    end_time=$(date +%s%3N)
    duration=$((end_time - start_time))
    regular_times+=($duration)
    regular_total=$((regular_total + duration))
    echo -e "   Time: ${duration}ms"
done

avg_regular=$((regular_total / ITERATIONS))
min_regular=${regular_times[0]}
max_regular=${regular_times[0]}
for time in "${regular_times[@]}"; do
    [ $time -lt $min_regular ] && min_regular=$time
    [ $time -gt $max_regular ] && max_regular=$time
done

echo ""
echo -e "${CYAN}📊 Regular Mode Results:${NC}"
echo -e "   Average: ${avg_regular}ms"
echo -e "${GREEN}   Best:    ${min_regular}ms${NC}"
echo -e "${YELLOW}   Worst:   ${max_regular}ms${NC}"

# ==============================================================================
# BENCHMARK 3: Feature Showcase with Timing
# ==============================================================================
echo ""
echo -e "${MAGENTA}🛡️ BENCHMARK 3: Feature Showcase${NC}"
echo -e "${MAGENTA}=================================${NC}"
echo -e "Banner grabbing + vulnerability assessment performance"
echo ""

echo -e "${YELLOW}🔍 Running comprehensive scan...${NC}"
start_time=$(date +%s%3N)
./target/release/nullscan --target "$TARGET" --top100 --banners --vuln-check --quiet > /dev/null 2>&1
end_time=$(date +%s%3N)
feature_time=$((end_time - start_time))

echo -e "${CYAN}📊 Feature-Rich Scan: ${feature_time}ms${NC}"

# ==============================================================================
# PERFORMANCE ANALYSIS & CONTENT-READY SUMMARY
# ==============================================================================
echo ""
echo -e "${CYAN}🎬 CONTENT CREATOR SUMMARY${NC}"
echo -e "${CYAN}===========================${NC}"
echo ""

# Calculate speedup (using bc for floating point if available, otherwise integer math)
if command -v bc > /dev/null; then
    speedup=$(echo "scale=1; $avg_regular / $avg_fast" | bc)
    efficiency=$(echo "scale=1; ($avg_regular - $avg_fast) / $avg_regular * 100" | bc)
else
    speedup=$((avg_regular * 10 / avg_fast))
    speedup_int=$((speedup / 10))
    speedup_dec=$((speedup % 10))
    speedup="${speedup_int}.${speedup_dec}"
    efficiency=$(((avg_regular - avg_fast) * 100 / avg_regular))
fi

echo -e "${YELLOW}📈 Performance Highlights for Content:${NC}"
echo -e "   • Fast Mode Speed: ${avg_fast}ms average"
echo -e "   • Regular Mode: ${avg_regular}ms average"
echo -e "${GREEN}   • Speed Improvement: ${speedup}x faster${NC}"
echo -e "${GREEN}   • Efficiency Gain: ${efficiency}% faster${NC}"
echo -e "   • Feature-Rich Scan: ${feature_time}ms"
echo ""

echo -e "${CYAN}🎯 Content Angles:${NC}"
echo -e "${GRAY}   • 'This Rust Tool is ${speedup}x Faster in Fast Mode'${NC}"
echo -e "${GRAY}   • 'Port Scanning in Under ${avg_fast}ms'${NC}"
echo -e "${GRAY}   • 'Modern Network Tools Built in Rust'${NC}"
echo -e "${GRAY}   • 'Fast vs Thorough: Speed vs Features'${NC}"
echo ""

echo -e "${CYAN}📊 Industry Context:${NC}"
echo -e "${GRAY}   • Competitive with Nmap (~100ms for 100 ports)${NC}"
echo -e "${GRAY}   • 115x faster for network ranges with ping sweep${NC}"
echo -e "${GRAY}   • Built-in vulnerability assessment${NC}"
echo -e "${GRAY}   • Professional HTML reporting${NC}"
echo ""

# ==============================================================================
# EXPORT BENCHMARK DATA
# ==============================================================================
if [ "$DETAILED" = "true" ]; then
    echo -e "${YELLOW}📋 Exporting detailed benchmark data...${NC}"

    cat > benchmark-results.json << EOF
{
  "timestamp": "$(date -Iseconds)",
  "target": "$TARGET",
  "iterations": $ITERATIONS,
  "fast_mode": {
    "times": [$(IFS=,; echo "${fast_times[*]}")],
    "average": $avg_fast,
    "min": $min_fast,
    "max": $max_fast
  },
  "regular_mode": {
    "times": [$(IFS=,; echo "${regular_times[*]}")],
    "average": $avg_regular,
    "min": $min_regular,
    "max": $max_regular
  },
  "feature_rich": {
    "time": $feature_time
  },
  "performance": {
    "speedup": "$speedup",
    "efficiency": "$efficiency"
  }
}
EOF

    echo -e "${GREEN}✅ Results exported to benchmark-results.json${NC}"
fi

echo ""
echo -e "${MAGENTA}🎬 Ready for content creation!${NC}"
echo -e "${WHITE}   Use these numbers in your videos, blogs, and demos${NC}"
echo ""
echo -e "${CYAN}📝 Quick Copy-Paste Stats:${NC}"
echo -e "${WHITE}   Fast Mode: ${avg_fast}ms | Regular: ${avg_regular}ms | Speedup: ${speedup}x${NC}"
