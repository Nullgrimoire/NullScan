#!/usr/bin/env pwsh

# NullScan Usage Examples
# Demonstrate various features including ping sweep and parallel scanning

# Check if we're in CI mode
$CI_MODE = $env:CI_MODE -eq "1"

Write-Host "🔍 NullScan Usage Examples" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

# Build the project first
Write-Host "`n📦 Building NullScan..." -ForegroundColor Yellow
cargo build --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

# Set up PowerShell alias for easier usage
Write-Host "`n🔧 Setting up PowerShell alias..." -ForegroundColor Yellow
Set-Alias nullscan ".\target\release\nullscan.exe"
Write-Host "✅ Alias 'nullscan' created! You can now use 'nullscan' directly." -ForegroundColor Green

Write-Host "`n💡 Tip: To make this permanent, add this to your PowerShell profile:" -ForegroundColor Cyan
Write-Host "   Add-Content `$PROFILE `"Set-Alias nullscan \`"$PWD\target\release\nullscan.exe\`"`"" -ForegroundColor Gray

Write-Host "`n✅ Build successful!`n" -ForegroundColor Green

# Example 1: Basic scan
Write-Host "🎯 Example 1: Basic scan of localhost with top 100 ports" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 127.0.0.1 --top100"
if ($CI_MODE) {
    Write-Host "(CI Mode: Skipping actual scan, showing help instead)" -ForegroundColor Yellow
    & nullscan --help | Select-Object -First 10
} else {
    & nullscan --target 127.0.0.1 --top100
}

Write-Host "`n" + "="*80

# Example 2: Network range scan (CIDR)
Write-Host "`n🎯 Example 2: Network range scan with CIDR notation" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 127.0.0.1/31 --ports 80,443 --verbose"
if ($CI_MODE) {
    Write-Host "(CI Mode: Showing version instead)" -ForegroundColor Yellow
    & nullscan --version
} else {
    & nullscan --target 127.0.0.1/31 --ports 80,443 --verbose
}

Write-Host "`n" + "="*80

# Example 2.5: Ping sweep demonstration
Write-Host "`n🎯 Example 2.5: Ping sweep for efficient network scanning" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose"
Write-Host "(This will ping sweep first to find live hosts, then scan only reachable ones)"
if ($CI_MODE) {
    Write-Host "(CI Mode: Showing ping sweep feature info)" -ForegroundColor Yellow
    Write-Host "Ping sweep optimizes scanning by testing host availability first"
} else {
    & nullscan --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose
}

Write-Host "`n" + "="*80

# Example 3: Custom ports with banners
Write-Host "`n🎯 Example 3: Scan specific ports with banner grabbing" -ForegroundColor Magenta
Write-Host "Command: nullscan --target google.com --ports 80,443 --banners --format json"
if ($CI_MODE) {
    Write-Host "(CI Mode: Showing JSON format example)" -ForegroundColor Yellow
    Write-Host '{"target":"example.com","ports":[{"port":80,"state":"open","service":"http","banner":"Server: nginx/1.18.0"}]}'
} else {
    & nullscan --target google.com --ports 80,443 --banners --format json
}

Write-Host "`n" + "="*80

# Example 4: Range scan with CSV output
Write-Host "`n🎯 Example 4: Port range scan with CSV export" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv"
if ($CI_MODE) {
    Write-Host "(CI Mode: Showing CSV format example)" -ForegroundColor Yellow
    $sampleCsv = @"
host,port,state,service,banner
127.0.0.1,135,closed,msrpc,
127.0.0.1,139,closed,netbios-ssn,
"@
    Write-Host $sampleCsv
    $sampleCsv | Out-File -FilePath "localhost_range.csv" -Encoding UTF8
} else {
    & nullscan --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv
}

if (Test-Path "localhost_range.csv") {
    Write-Host "`n📄 Generated CSV file:" -ForegroundColor Green
    Get-Content "localhost_range.csv" | Write-Host
}

Write-Host "`n" + "="*80

# Example 5: Network scanning demo (limited range)
Write-Host "`n🎯 Example 5: Small network range scan" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 192.168.1.1/30 --ports 80,443 --timeout 1000 --verbose"
Write-Host "(Scanning a /30 network - 2 hosts)"
if ($CI_MODE) {
    Write-Host "(CI Mode: Showing network range concept)" -ForegroundColor Yellow
    Write-Host "CIDR notation /30 represents 2 usable host addresses"
} else {
    & nullscan --target 192.168.1.1/30 --ports 80,443 --timeout 1000 --verbose
}

Write-Host "`n🎉 Examples completed!" -ForegroundColor Green
Write-Host "📚 For more options, run: nullscan --help" -ForegroundColor Cyan
Write-Host "🌐 Network range scanning examples:" -ForegroundColor Cyan
Write-Host "  - Local subnet: nullscan --target 192.168.1.0/24 --top100" -ForegroundColor Gray
Write-Host "  - Corporate range: nullscan --target 10.0.0.0/16 --top1000 --format json" -ForegroundColor Gray
Write-Host "  - Small range: nullscan --target 172.16.0.0/28 --ports 22,80,443" -ForegroundColor Gray

# Cleanup demo files
Write-Host "`n🧹 Cleaning up demo files..." -ForegroundColor Yellow
Remove-Item -Path "localhost_range.csv" -ErrorAction SilentlyContinue
Write-Host "✅ Cleanup completed!" -ForegroundColor Green

Write-Host "`nHappy scanning! 🔍✨" -ForegroundColor Green
