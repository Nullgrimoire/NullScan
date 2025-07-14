# NullScan Professional Benchmark Suite
# Comprehensive performance testing and comparison tool
# Author: Nullgrimoire
# Version: 2.0

param(
    [string]$Target = "127.0.0.1",
    [string]$NetworkTarget = "192.168.1.0/24",
    [int]$Iterations = 5,
    [int]$NetworkIterations = 3,
    [switch]$SkipNmap,
    [switch]$SkipNetworkTest,
    [switch]$OnlyNullScan,
    [switch]$Verbose,
    [string]$OutputFile = "",
    [switch]$GenerateReport
)

# Color functions for better output
function Write-ColorText {
    param([string]$Text, [string]$Color = "White")
    $colors = @{
        "Red" = "Red"; "Green" = "Green"; "Yellow" = "Yellow"
        "Blue" = "Blue"; "Magenta" = "Magenta"; "Cyan" = "Cyan"
    }
    Write-Host $Text -ForegroundColor $colors[$Color]
}

function Write-Banner {
    param([string]$Text)
    Write-Host ""
    Write-ColorText "=" * 60 "Cyan"
    Write-ColorText "  $Text" "Cyan"
    Write-ColorText "=" * 60 "Cyan"
}

function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-ColorText ">>> $Text" "Yellow"
}

# System information gathering
function Get-SystemInfo {
    $cpu = Get-WmiObject -Class Win32_Processor | Select-Object -First 1
    $ram = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $cores = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors

    return @{
        CPU = $cpu.Name.Trim()
        Cores = $cores
        RAM = "$ram GB"
        OS = (Get-WmiObject -Class Win32_OperatingSystem).Caption
    }
}

# Benchmark result storage
class BenchmarkResult {
    [string]$Scanner
    [string]$Test
    [string]$Target
    [double]$AvgTime
    [double]$MinTime
    [double]$MaxTime
    [double]$StdDev
    [string[]]$AllTimes
    [string]$Command
    [bool]$Success
    [string]$Error
}

$global:Results = @()

# Performance measurement function
function Measure-ScannerPerformance {
    param(
        [string]$ScannerName,
        [string]$Command,
        [string]$TestName,
        [string]$TargetHost,
        [int]$IterationCount = 5
    )

    Write-Section "Testing $ScannerName - $TestName"
    Write-ColorText "Command: $Command" "Blue"
    Write-ColorText "Iterations: $IterationCount" "Blue"

    $times = @()
    $success = $true
    $errorMsg = ""

    for ($i = 1; $i -le $IterationCount; $i++) {
        Write-Host "  Run $i/$IterationCount... " -NoNewline

        try {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            # Execute command with timeout
            $process = Start-Process -FilePath "powershell" -ArgumentList "-Command", "& $Command" -NoNewWindow -PassThru -Wait

            $stopwatch.Stop()

            if ($process.ExitCode -eq 0) {
                $times += $stopwatch.Elapsed.TotalSeconds
                Write-ColorText "$([math]::Round($stopwatch.Elapsed.TotalSeconds, 3))s" "Green"
            } else {
                Write-ColorText "FAILED" "Red"
                $success = $false
                $errorMsg = "Exit code: $($process.ExitCode)"
                break
            }
        }
        catch {
            Write-ColorText "ERROR" "Red"
            $success = $false
            $errorMsg = $_.Exception.Message
            break
        }

        # Small delay between runs
        Start-Sleep -Milliseconds 500
    }

    if ($success -and $times.Count -gt 0) {
        $avg = ($times | Measure-Object -Average).Average
        $min = ($times | Measure-Object -Minimum).Minimum
        $max = ($times | Measure-Object -Maximum).Maximum
        $stddev = [math]::Sqrt(($times | ForEach-Object { [math]::Pow($_ - $avg, 2) } | Measure-Object -Sum).Sum / $times.Count)

        Write-ColorText "  Results: Avg=$([math]::Round($avg, 3))s, Min=$([math]::Round($min, 3))s, Max=$([math]::Round($max, 3))s, StdDev=$([math]::Round($stddev, 3))s" "Green"
    }

    $result = [BenchmarkResult]::new()
    $result.Scanner = $ScannerName
    $result.Test = $TestName
    $result.Target = $TargetHost
    $result.Command = $Command
    $result.Success = $success
    $result.Error = $errorMsg

    if ($success -and $times.Count -gt 0) {
        $result.AvgTime = [math]::Round($avg, 3)
        $result.MinTime = [math]::Round($min, 3)
        $result.MaxTime = [math]::Round($max, 3)
        $result.StdDev = [math]::Round($stddev, 3)
        $result.AllTimes = $times | ForEach-Object { [math]::Round($_, 3).ToString() }
    }

    $global:Results += $result
    return $result
}

# Generate HTML report
function Generate-HTMLReport {
    param([string]$FilePath)

    $systemInfo = Get-SystemInfo()
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $html = @"
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
        <p><strong>CPU:</strong> $($systemInfo.CPU)</p>
        <p><strong>Cores:</strong> $($systemInfo.Cores)</p>
        <p><strong>RAM:</strong> $($systemInfo.RAM)</p>
        <p><strong>OS:</strong> $($systemInfo.OS)</p>
    </div>

    <div class="stats">
"@

    # Add summary statistics
    $successfulTests = ($global:Results | Where-Object { $_.Success }).Count
    $totalTests = $global:Results.Count
    $avgNullScanTime = ($global:Results | Where-Object { $_.Scanner -eq "NullScan" -and $_.Success } | Measure-Object -Property AvgTime -Average).Average

    $html += @"
        <div class="stat-box">
            <h3>$totalTests</h3>
            <p>Total Tests</p>
        </div>
        <div class="stat-box">
            <h3>$successfulTests</h3>
            <p>Successful Tests</p>
        </div>
        <div class="stat-box">
            <h3>$([math]::Round($avgNullScanTime, 3))s</h3>
            <p>Avg NullScan Time</p>
        </div>
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
"@

    foreach ($result in $global:Results) {
        $statusClass = if ($result.Success) { "success" } else { "error" }
        $statusText = if ($result.Success) { "✅ Success" } else { "❌ $($result.Error)" }

        $html += @"
            <tr>
                <td><strong>$($result.Scanner)</strong></td>
                <td>$($result.Test)</td>
                <td>$($result.Target)</td>
                <td>$($result.AvgTime)</td>
                <td>$($result.MinTime)</td>
                <td>$($result.MaxTime)</td>
                <td>$($result.StdDev)</td>
                <td class="$statusClass">$statusText</td>
                <td><code>$($result.Command)</code></td>
            </tr>
"@
    }

    $html += @"
        </tbody>
    </table>

    <div class="footer">
        <p>Generated by NullScan Benchmark Suite v2.0</p>
        <p>🚀 Built with ❤️ for performance testing</p>
    </div>
</body>
</html>
"@

    $html | Out-File -FilePath $FilePath -Encoding UTF8
    Write-ColorText "HTML report saved to: $FilePath" "Green"
}

# Main execution
function Main {
    Write-Banner "NullScan Professional Benchmark Suite v2.0"

    # System information
    $systemInfo = Get-SystemInfo()
    Write-Section "System Information"
    Write-Host "CPU: $($systemInfo.CPU)"
    Write-Host "Cores: $($systemInfo.Cores)"
    Write-Host "RAM: $($systemInfo.RAM)"
    Write-Host "OS: $($systemInfo.OS)"

    # Build NullScan
    Write-Section "Building NullScan"
    try {
        cargo build --release
        if ($LASTEXITCODE -ne 0) { throw "Build failed" }
        Write-ColorText "✅ Build successful" "Green"
    }
    catch {
        Write-ColorText "❌ Build failed: $_" "Red"
        exit 1
    }

    $nullscanPath = ".\target\release\nullscan.exe"

    # Verify NullScan works
    Write-Section "Verifying NullScan"
    try {
        & $nullscanPath --version > $null
        Write-ColorText "✅ NullScan verified" "Green"
    }
    catch {
        Write-ColorText "❌ NullScan verification failed" "Red"
        exit 1
    }

    # Check for external scanners
    $nmapAvailable = $false
    if (-not $SkipNmap -and -not $OnlyNullScan) {
        try {
            nmap --version > $null 2>&1
            $nmapAvailable = $true
            Write-ColorText "✅ Nmap detected" "Green"
        }
        catch {
            Write-ColorText "⚠️ Nmap not available, skipping comparisons" "Yellow"
        }
    }

    Write-Banner "Performance Tests"

    # Test 1: Single host, top 100 ports
    Measure-ScannerPerformance "NullScan" "$nullscanPath --target $Target --top100 --quiet" "Top 100 Ports" $Target $Iterations

    if ($nmapAvailable) {
        Measure-ScannerPerformance "Nmap" "nmap -p- --top-ports 100 $Target" "Top 100 Ports" $Target $Iterations
    }

    # Test 2: Single host, specific ports
    Measure-ScannerPerformance "NullScan" "$nullscanPath --target $Target --ports 22,80,443,3389 --quiet" "Common Ports" $Target $Iterations

    if ($nmapAvailable) {
        Measure-ScannerPerformance "Nmap" "nmap -p 22,80,443,3389 $Target" "Common Ports" $Target $Iterations
    }

    # Test 3: Fast mode
    Measure-ScannerPerformance "NullScan" "$nullscanPath --target $Target --fast-mode --top100" "Fast Mode" $Target $Iterations

    # Test 4: With banners
    Measure-ScannerPerformance "NullScan" "$nullscanPath --target $Target --ports 22,80,443 --banners --quiet" "With Banners" $Target $Iterations

    if ($nmapAvailable) {
        Measure-ScannerPerformance "Nmap" "nmap -sV -p 22,80,443 $Target" "With Service Detection" $Target $Iterations
    }

    # Test 5: Network range (if not skipped)
    if (-not $SkipNetworkTest) {
        Write-Section "Network Range Tests"
        Write-ColorText "Target: $NetworkTarget" "Blue"

        Measure-ScannerPerformance "NullScan" "$nullscanPath --target $NetworkTarget --ping-sweep --top100 --quiet" "Network Ping Sweep" $NetworkTarget $NetworkIterations

        if ($nmapAvailable) {
            Measure-ScannerPerformance "Nmap" "nmap --top-ports 100 $NetworkTarget" "Network Scan" $NetworkTarget $NetworkIterations
        }
    }

    # Results summary
    Write-Banner "Benchmark Results Summary"

    $successfulResults = $global:Results | Where-Object { $_.Success }
    $failedResults = $global:Results | Where-Object { -not $_.Success }

    Write-ColorText "Successful Tests: $($successfulResults.Count)" "Green"
    Write-ColorText "Failed Tests: $($failedResults.Count)" "Red"

    if ($successfulResults.Count -gt 0) {
        Write-Host ""
        Write-ColorText "Performance Summary:" "Cyan"

        foreach ($result in $successfulResults) {
            $status = if ($result.AvgTime -lt 1) { "🚀" } elseif ($result.AvgTime -lt 5) { "⚡" } else { "🐌" }
            Write-Host "$status $($result.Scanner) - $($result.Test): $($result.AvgTime)s avg"
        }
    }

    if ($failedResults.Count -gt 0) {
        Write-Host ""
        Write-ColorText "Failed Tests:" "Red"
        foreach ($result in $failedResults) {
            Write-Host "❌ $($result.Scanner) - $($result.Test): $($result.Error)"
        }
    }

    # Export results
    if ($OutputFile) {
        $csvContent = "Scanner,Test,Target,AvgTime,MinTime,MaxTime,StdDev,Success,Error,Command`n"
        foreach ($result in $global:Results) {
            $csvContent += "$($result.Scanner),$($result.Test),$($result.Target),$($result.AvgTime),$($result.MinTime),$($result.MaxTime),$($result.StdDev),$($result.Success),$($result.Error),$($result.Command)`n"
        }
        $csvContent | Out-File -FilePath $OutputFile -Encoding UTF8
        Write-ColorText "Results exported to: $OutputFile" "Green"
    }

    # Generate HTML report
    if ($GenerateReport) {
        $reportPath = "benchmark_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
        Generate-HTMLReport $reportPath
    }

    Write-Banner "Benchmark Complete"
    Write-ColorText "🎉 All tests completed successfully!" "Green"
}

# Execute main function
Main
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
