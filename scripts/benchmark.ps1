# NullScan Performance Benchmark Script
# Compares NullScan against other popular TCP scanners
#
# Examples:
#   .\benchmark.ps1                                    # Basic localhost test
#   .\benchmark.ps1 -SkipExternalScanners             # Only test NullScan
#   .\benchmark.ps1 -NetworkTarget "192.168.1.0/24"   # Include network range test
#   .\benchmark.ps1 -ForceNetworkTest                  # Force network test even with default target
#   .\benchmark.ps1 -Iterations 10                     # Run more iterations for accuracy
#   .\benchmark.ps1 -NetworkIterations 3               # Limit network tests to 3 iterations (for slow networks)

param(
    [string]$Target = "127.0.0.1",
    [string]$NetworkTarget = "10.0.0.0/22",
    [int]$Iterations = 10,
    [int]$NetworkIterations = 3,
    [switch]$SkipExternalScanners,
    [switch]$ForceNetworkTest,
    [switch]$SkipNetworkTest
)

Write-Host "🔍 NullScan Performance Benchmark" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Record start time for total benchmark duration
$testStartTime = Get-Date

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
        [string]$TestName,
        [int]$CustomIterations = $Iterations
    )

    Write-Host "`n🚀 Testing $ScannerName - $TestName" -ForegroundColor Blue

    $times = @()
    for ($i = 1; $i -le $CustomIterations; $i++) {
        Write-Host "  Run $i/$CustomIterations..." -NoNewline

        $startTime = Get-Date
        try {
            Invoke-Expression $Command 2>&1 | Out-Null
            $endTime = Get-Date
            $duration = ($endTime - $startTime).TotalSeconds
            $times += $duration
            Write-Host " ${duration:F2}s" -ForegroundColor Green
        }
        catch {
            Write-Host " FAILED - $($_.Exception.Message)" -ForegroundColor Red
            return $null
        }
    }

    if ($times.Count -eq 0) {
        Write-Host "❌ All runs failed for $ScannerName" -ForegroundColor Red
        return $null
    }

    $avgTime = ($times | Measure-Object -Average).Average
    $minTime = ($times | Measure-Object -Minimum).Minimum
    $maxTime = ($times | Measure-Object -Maximum).Maximum

    return @{
        Scanner     = $ScannerName
        Test        = $TestName
        Command     = $Command
        AverageTime = [math]::Round($avgTime, 2)
        MinTime     = [math]::Round($minTime, 2)
        MaxTime     = [math]::Round($maxTime, 2)
        Times       = $times
        Timestamp   = (Get-Date)
    }
}

# Test 1: Single Host - Top 100 Ports
Write-Host "`n📊 Benchmark 1: Single Host Top 100 Ports ($Target)" -ForegroundColor Magenta

$result = Measure-ScannerPerformance "NullScan" "$nullscanPath --target $Target --ports 1-100 --fast-mode" "Single Host Top 100"
if ($result) { $results += $result }

if (-not $SkipExternalScanners) {
    if (Get-Command nmap -ErrorAction SilentlyContinue) {
        $result = Measure-ScannerPerformance "Nmap" "nmap -p1-100 -T4 -Pn $Target" "Single Host Top 100"
        if ($result) { $results += $result }
    }
    else {
        Write-Host "⚠️  Nmap not found - skipping nmap benchmarks" -ForegroundColor Yellow
    }
}

# Test 2: Large Port Range - Single Host
Write-Host "`n📊 Benchmark 2: Large Port Range ($Target) ports 1-1000" -ForegroundColor Magenta

$result = Measure-ScannerPerformance "NullScan" "$nullscanPath --target $Target --ports 1-1000 --fast-mode" "Large Port Range"
if ($result) { $results += $result }

if (-not $SkipExternalScanners) {
    if (Get-Command nmap -ErrorAction SilentlyContinue) {
        $result = Measure-ScannerPerformance "Nmap" "nmap -p1-1000 -T4 -Pn $Target" "Large Port Range"
        if ($result) { $results += $result }
    }
}

# Test 3: Network Range (if network target is specified and different from localhost, or forced)
if (-not $SkipNetworkTest -and ($ForceNetworkTest -or ($NetworkTarget -ne "127.0.0.1/32" -and $NetworkTarget -ne "127.0.0.1" -and $NetworkTarget -ne "localhost" -and $NetworkTarget -ne ""))) {
    Write-Host "`n📊 Benchmark 3: Network Range ($NetworkTarget)" -ForegroundColor Magenta
    Write-Host "   Note: This test scans multiple hosts and may take longer (using $NetworkIterations iterations)" -ForegroundColor Yellow

    $result = Measure-ScannerPerformance "NullScan" "$nullscanPath --target `"$NetworkTarget`" --top100 --ping-sweep --fast-mode --max-hosts 40" "Network Range" $NetworkIterations
    if ($result) { $results += $result }

    if (-not $SkipExternalScanners) {
        if (Get-Command nmap -ErrorAction SilentlyContinue) {
            $result = Measure-ScannerPerformance "Nmap" "nmap --top-ports 100 -T4 `"$NetworkTarget`"" "Network Range" $NetworkIterations
            if ($result) { $results += $result }
        }
    }
}
else {
    Write-Host "`n⚠️  Skipping network range test" -ForegroundColor Yellow
    Write-Host "    Use -ForceNetworkTest to run anyway, or specify a different -NetworkTarget" -ForegroundColor Gray
}

# Display Results
Write-Host "`n🏆 BENCHMARK RESULTS" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green

if ($results.Count -eq 0) {
    Write-Host "No benchmark results to display" -ForegroundColor Red
    exit
}

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

    if ($sortedResults.Count -gt 1) {
        $fastest = $sortedResults[0]
        Write-Host "`n🥇 Winner: $($fastest.Scanner) ($($fastest.AverageTime)s)" -ForegroundColor Green

        for ($i = 1; $i -lt $sortedResults.Count; $i++) {
            $slower = $sortedResults[$i]
            if ($fastest.AverageTime -gt 0) {
                $speedRatio = [math]::Round($slower.AverageTime / $fastest.AverageTime, 1)
                Write-Host "   $($slower.Scanner) is ${speedRatio}x slower" -ForegroundColor Yellow
            }
            else {
                Write-Host "   $($slower.Scanner) - comparison unavailable" -ForegroundColor Yellow
            }
        }
    }
}

# Generate CSV report
$csvPath = "benchmark_results_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "`n📄 Detailed results saved to: $csvPath" -ForegroundColor Blue

# Summary statistics
if ($results.Count -gt 0) {
    Write-Host "`n📈 BENCHMARK SUMMARY" -ForegroundColor Green
    Write-Host "====================" -ForegroundColor Green

    $nullscanResults = $results | Where-Object { $_.Scanner -eq "NullScan" }
    if ($nullscanResults.Count -gt 0) {
        $avgSpeed = ($nullscanResults | Measure-Object -Property AverageTime -Average).Average
        Write-Host "🚀 NullScan Average Performance: $([math]::Round($avgSpeed, 2))s per test" -ForegroundColor Cyan

        # Compare with other scanners if available
        $otherResults = $results | Where-Object { $_.Scanner -ne "NullScan" }
        if ($otherResults.Count -gt 0) {
            $otherAvg = ($otherResults | Measure-Object -Property AverageTime -Average).Average
            $speedup = [math]::Round($otherAvg / $avgSpeed, 1)
            Write-Host "⚡ NullScan is ${speedup}x faster on average than other scanners" -ForegroundColor Green
        }
    }

    Write-Host "`n🎯 Total tests completed: $($results.Count)" -ForegroundColor Blue
    Write-Host "⏱️  Total benchmark time: $([math]::Round(((Get-Date) - $testStartTime).TotalSeconds, 1))s" -ForegroundColor Blue
}

# Performance tips
Write-Host "`n💡 Performance Tips:" -ForegroundColor Cyan
Write-Host "• Use --ping-sweep for network ranges to skip dead hosts"
Write-Host "• Increase --max-hosts for faster network scanning"
Write-Host "• Adjust --concurrency based on your system capabilities"
Write-Host "• Use --timeout to control scan speed vs accuracy"

Write-Host "`n✅ Benchmark complete!" -ForegroundColor Green
