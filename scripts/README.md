# NullScan Simplified Benchmark Scripts

These simplified benchmark scripts provide quick and easy performance testing for NullScan without the complexity of the previous versions.

## Features

- **Simple and fast** - No complex configurations or external dependencies
- **3 essential tests** - Top 100 ports, Common ports with banners, Fast mode
- **Easy to use** - Just run with target and iterations
- **Clear output** - Color-coded results with timing information
- **CSV export** - Results automatically saved to timestamped CSV files

## PowerShell Script (benchmark.ps1)

### Usage
```powershell
.\scripts\benchmark.ps1 [target] [iterations]
```

### Parameters
- `Target` - Target IP or hostname (default: 127.0.0.1)
- `Iterations` - Number of test iterations (default: 3)
- `Verbose` - Enable verbose output (optional)

### Examples
```powershell
# Basic benchmark with default settings
.\scripts\benchmark.ps1

# Benchmark specific target with 5 iterations
.\scripts\benchmark.ps1 -Target 192.168.1.1 -Iterations 5

# Verbose output
.\scripts\benchmark.ps1 -Target example.com -Iterations 3 -Verbose
```

## Bash Script (benchmark.sh)

### Usage
```bash
./scripts/benchmark.sh [target] [iterations]
```

### Parameters
- `target` - Target IP or hostname (default: 127.0.0.1)
- `iterations` - Number of test iterations (default: 3)

### Examples
```bash
# Basic benchmark with default settings
./scripts/benchmark.sh

# Benchmark specific target with 5 iterations
./scripts/benchmark.sh 192.168.1.1 5

# Local testing
./scripts/benchmark.sh localhost 2
```

## Test Types

### Test 1: Top 100 Ports
- Scans the most common 100 ports
- Uses `--top100` flag
- Good for general port discovery

### Test 2: Common Ports with Banners
- Scans ports 22, 80, 443, 3389
- Includes banner grabbing (`--banners`)
- Tests service detection capabilities

### Test 3: Fast Mode
- Uses `--fast-mode` with top 100 ports
- Optimized for speed
- Demonstrates high-performance scanning

## Output

The scripts provide:
- **Real-time progress** - Shows timing for each test run
- **Summary results** - Average times for each test
- **Fastest test identification** - Highlights the best performing test
- **CSV export** - Timestamped results file for analysis

### Sample Output
```
Starting benchmark tests on 127.0.0.1...
Running 3 iterations per test

Test 1: Top 100 ports scan
  Run 1/3... 2.04s
  Run 2/3... 1.98s
  Run 3/3... 2.01s
  Average: 2.01s

Test 2: Common ports with banners
  Run 1/3... 2.15s
  Run 2/3... 2.10s
  Run 3/3... 2.12s
  Average: 2.12s

Test 3: Fast mode scan
  Run 1/3... 0.13s
  Run 2/3... 0.12s
  Run 3/3... 0.14s
  Average: 0.13s

==================================================
BENCHMARK RESULTS
==================================================
Target: 127.0.0.1
Iterations per test: 3

Test 1 - Top 100 ports:      2.01s
Test 2 - Common ports+banners: 2.12s
Test 3 - Fast mode:          0.13s

Fastest test: Fast mode (0.13s)
Results saved to: benchmark_results_20250714_210101.csv
Benchmark complete!
```

## CSV Export

Results are automatically saved to a timestamped CSV file with the following format:
- `Test` - Test name
- `AverageTime` - Average execution time
- `AllTimes` - All individual timing results (semicolon-separated)

## Requirements

- **Rust/Cargo** - For building NullScan
- **PowerShell** - For Windows script
- **Bash** - For Linux/macOS script (requires `bc` for calculations)

## Changes from Previous Version

The simplified scripts remove:
- Complex HTML report generation
- System information gathering
- External scanner comparisons (Nmap)
- Network range testing
- Advanced configuration options
- Complex error handling and classes
- Multiple output formats

This makes the scripts much easier to understand, maintain, and use for quick performance testing.
