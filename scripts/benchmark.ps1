# NullScan Simple Benchmark Script
# Quick performance testing for NullScan
# Usage: .\benchmark.ps1 [target] [iterations]

param(
    [string]$Target = "127.0.0.1",
    [int]$Iterations = 3,
    [switch]$Verbose
)

# Build NullScan
Write-Host "Building NullScan..." -ForegroundColor Yellow
cargo build --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

$nullscan = ".\target\release\nullscan.exe"

# Check if NullScan works
Write-Host "Verifying NullScan..." -ForegroundColor Yellow
& $nullscan --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "NullScan verification failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`nStarting benchmark tests on $Target..." -ForegroundColor Green
Write-Host "Running $Iterations iterations per test`n" -ForegroundColor Blue

# Test 1: Top 100 ports
Write-Host "Test 1: Top 100 ports scan" -ForegroundColor Cyan
$times1 = @()
for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "  Run $i/$Iterations... " -NoNewline
    $start = Get-Date
    & $nullscan --target $Target --top100 --quiet 2>&1 | Out-Null
    $end = Get-Date
    $duration = ($end - $start).TotalSeconds
    $times1 += $duration
    Write-Host "$([math]::Round($duration, 2))s" -ForegroundColor Green
}
$avg1 = [math]::Round(($times1 | Measure-Object -Average).Average, 2)
Write-Host "  Average: ${avg1}s" -ForegroundColor Yellow

# Test 2: Common ports with banners
Write-Host "`nTest 2: Common ports with banners" -ForegroundColor Cyan
$times2 = @()
for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "  Run $i/$Iterations... " -NoNewline
    $start = Get-Date
    & $nullscan --target $Target --ports 22, 80, 443, 3389 --banners --quiet 2>&1 | Out-Null
    $end = Get-Date
    $duration = ($end - $start).TotalSeconds
    $times2 += $duration
    Write-Host "$([math]::Round($duration, 2))s" -ForegroundColor Green
}
$avg2 = [math]::Round(($times2 | Measure-Object -Average).Average, 2)
Write-Host "  Average: ${avg2}s" -ForegroundColor Yellow

# Test 3: Fast mode
Write-Host "`nTest 3: Fast mode scan" -ForegroundColor Cyan
$times3 = @()
for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "  Run $i/$Iterations... " -NoNewline
    $start = Get-Date
    & $nullscan --target $Target --fast-mode --top100 --quiet 2>&1 | Out-Null
    $end = Get-Date
    $duration = ($end - $start).TotalSeconds
    $times3 += $duration
    Write-Host "$([math]::Round($duration, 2))s" -ForegroundColor Green
}
$avg3 = [math]::Round(($times3 | Measure-Object -Average).Average, 2)
Write-Host "  Average: ${avg3}s" -ForegroundColor Yellow

# Results summary
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "BENCHMARK RESULTS" -ForegroundColor Green
Write-Host "="*50 -ForegroundColor Cyan
Write-Host "Target: $Target" -ForegroundColor White
Write-Host "Iterations per test: $Iterations" -ForegroundColor White
Write-Host ""
Write-Host "Test 1 - Top 100 ports:      ${avg1}s" -ForegroundColor White
Write-Host "Test 2 - Common ports+banners: ${avg2}s" -ForegroundColor White
Write-Host "Test 3 - Fast mode:          ${avg3}s" -ForegroundColor White
Write-Host ""

# Find fastest test
$results = @(
    @{Name = "Top 100 ports"; Time = $avg1 },
    @{Name = "Common ports+banners"; Time = $avg2 },
    @{Name = "Fast mode"; Time = $avg3 }
)
$fastest = $results | Sort-Object Time | Select-Object -First 1
Write-Host "Fastest test: $($fastest.Name) (${$fastest.Time}s)" -ForegroundColor Green

# Save results to CSV
$csvFile = "benchmark_results_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$csvContent = "Test,AverageTime,AllTimes`n"
$csvContent += "Top100,$avg1,`"$($times1 -join ';')`"`n"
$csvContent += "CommonPorts,$avg2,`"$($times2 -join ';')`"`n"
$csvContent += "FastMode,$avg3,`"$($times3 -join ';')`"`n"
$csvContent | Out-File -FilePath $csvFile -Encoding UTF8

Write-Host "Results saved to: $csvFile" -ForegroundColor Blue
Write-Host "Benchmark complete!" -ForegroundColor Green
