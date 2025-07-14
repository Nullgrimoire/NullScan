# NullScan Performance Benchmark Script
# Compares NullScan against other popular TCP scanners

param(
    [string]$Target = "127.0.0.1",
    [string]$NetworkTarget = "192.168.1.0/24",
    [int]$Iterations = 3,
    [switch]$SkipExternalScanners
)

Write-Host "🔍 NullScan Performance Benchmark" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Build NullScan if needed
Write-Host "`n🔨 Building NullScan..." -ForegroundColor Yellow
cargo build --release
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build NullScan"
    exit 1
}

$nullscanPath = ".\target\release\nullscan.exe"

# Test if NullScan works
Write-Host "✅ Testing NullScan..." -ForegroundColor Green
& $nullscanPath --target $Target --ports 80 --timeout 1000 > $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "NullScan test failed"
    exit 1
}

# Benchmark results storage
$results = @()

function Measure-ScannerPerformance {
    param(
        [string]$ScannerName,
        [string]$Command,
        [string]$TestName
    )

    Write-Host "`n🚀 Testing $ScannerName - $TestName" -ForegroundColor Blue

    $times = @()
    for ($i = 1; $i -le $Iterations; $i++) {
        Write-Host "  Run $i/$Iterations..." -NoNewline

        $startTime = Get-Date
        try {
            Invoke-Expression $Command | Out-Null
            $endTime = Get-Date
            $duration = ($endTime - $startTime).TotalSeconds
            $times += $duration
            Write-Host " ${duration}s" -ForegroundColor Green
        }
        catch {
            Write-Host " FAILED" -ForegroundColor Red
            return $null
        }
    }

    $avgTime = ($times | Measure-Object -Average).Average
    $minTime = ($times | Measure-Object -Minimum).Minimum
    $maxTime = ($times | Measure-Object -Maximum).Maximum

    return @{
        Scanner = $ScannerName
        Test = $TestName
        AverageTime = [math]::Round($avgTime, 2)
        MinTime = [math]::Round($minTime, 2)
        MaxTime = [math]::Round($maxTime, 2)
        Times = $times
    }
}

# Test 1: Single Host - Top 100 Ports
Write-Host "`n📊 Benchmark 1: Single Host Top 100 Ports ($Target)" -ForegroundColor Magenta

$result = Measure-ScannerPerformance "NullScan" "$nullscanPath --target $Target --top100" "Single Host Top 100"
if ($result) { $results += $result }

if (-not $SkipExternalScanners) {
    # Test if nmap is available
    if (Get-Command nmap -ErrorAction SilentlyContinue) {
        $result = Measure-ScannerPerformance "Nmap" "nmap --top-ports 100 $Target" "Single Host Top 100"
        if ($result) { $results += $result }
    } else {
        Write-Host "⚠️  Nmap not found - skipping nmap benchmarks" -ForegroundColor Yellow
    }

    # Test if masscan is available
    if (Get-Command masscan -ErrorAction SilentlyContinue) {
        $result = Measure-ScannerPerformance "Masscan" "masscan -p1-100 $Target --rate 1000" "Single Host Top 100"
        if ($result) { $results += $result }
    } else {
        Write-Host "⚠️  Masscan not found - skipping masscan benchmarks" -ForegroundColor Yellow
    }
}

# Test 2: Large Port Range - Single Host
Write-Host "`n📊 Benchmark 2: Large Port Range ($Target ports 1-1000)" -ForegroundColor Magenta

$result = Measure-ScannerPerformance "NullScan" "$nullscanPath --target $Target --ports 1-1000" "Large Port Range"
if ($result) { $results += $result }

if (-not $SkipExternalScanners) {
    if (Get-Command nmap -ErrorAction SilentlyContinue) {
        $result = Measure-ScannerPerformance "Nmap" "nmap -p1-1000 $Target" "Large Port Range"
        if ($result) { $results += $result }
    }

    if (Get-Command masscan -ErrorAction SilentlyContinue) {
        $result = Measure-ScannerPerformance "Masscan" "masscan -p1-1000 $Target --rate 1000" "Large Port Range"
        if ($result) { $results += $result }
    }
}

# Test 3: Network Range (if not localhost)
if ($Target -ne "127.0.0.1" -and $NetworkTarget -ne "127.0.0.1/32") {
    Write-Host "`n📊 Benchmark 3: Network Range ($NetworkTarget)" -ForegroundColor Magenta

    $result = Measure-ScannerPerformance "NullScan" "$nullscanPath --target $NetworkTarget --top100 --max-hosts 5" "Network Range"
    if ($result) { $results += $result }

    if (-not $SkipExternalScanners) {
        if (Get-Command nmap -ErrorAction SilentlyContinue) {
            $result = Measure-ScannerPerformance "Nmap" "nmap --top-ports 100 $NetworkTarget" "Network Range"
            if ($result) { $results += $result }
        }
    }
}

# Display Results
Write-Host "`n🏆 BENCHMARK RESULTS" -ForegroundColor Green
Write-Host "====================" -ForegroundColor Green

if ($results.Count -eq 0) {
    Write-Host "No benchmark results to display" -ForegroundColor Red
    exit
}

# Group by test type
$testTypes = $results | Group-Object Test

foreach ($testGroup in $testTypes) {
    Write-Host "`n📊 $($testGroup.Name):" -ForegroundColor Cyan
    Write-Host $("-" * 50)

    $sortedResults = $testGroup.Group | Sort-Object AverageTime

    foreach ($result in $sortedResults) {
        $scanner = $result.Scanner.PadRight(15)
        $avg = "$($result.AverageTime)s".PadLeft(8)
        $min = "$($result.MinTime)s".PadLeft(8)
        $max = "$($result.MaxTime)s".PadLeft(8)

        Write-Host "$scanner | Avg: $avg | Min: $min | Max: $max"
    }

    # Show speed comparison
    if ($sortedResults.Count -gt 1) {
        $fastest = $sortedResults[0]
        Write-Host "`n🥇 Winner: $($fastest.Scanner) ($($fastest.AverageTime)s)" -ForegroundColor Green

        for ($i = 1; $i -lt $sortedResults.Count; $i++) {
            $slower = $sortedResults[$i]
            $speedRatio = [math]::Round($slower.AverageTime / $fastest.AverageTime, 1)
            Write-Host "   $($slower.Scanner) is ${speedRatio}x slower" -ForegroundColor Yellow
        }
    }
}

# Generate CSV report
$csvPath = "benchmark_results_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "`n📄 Detailed results saved to: $csvPath" -ForegroundColor Blue

# Performance tips
Write-Host "`n💡 Performance Tips:" -ForegroundColor Cyan
Write-Host "• Use --ping-sweep for network ranges to skip dead hosts"
Write-Host "• Increase --max-hosts for faster network scanning"
Write-Host "• Adjust --concurrency based on your system capabilities"
Write-Host "• Use --timeout to control scan speed vs accuracy"

Write-Host "`n✅ Benchmark complete!" -ForegroundColor Green
