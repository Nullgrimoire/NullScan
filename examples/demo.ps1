#!/usr/bin/env pwsh

# NullScan Usage Examples
# Demonstrate# Example 5: Parallel host scanning demo
Write-Host "`n🎯 Example 5: Parallel vs Sequential Host Scanning" -ForegroundColor Magenta
Write-Host "Testing sequential scanning (--max-hosts 1):"
Write-Host "Command: nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 1"
Measure-Command { & nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 1 } | ForEach-Object { Write-Host "Sequential time: $($_.TotalSeconds) seconds" -ForegroundColor Cyan }

Write-Host "`nTesting parallel scanning (--max-hosts 2):"
Write-Host "Command: nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 2"
Measure-Command { & nullscan --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 2 } | ForEach-Object { Write-Host "Parallel time: $($_.TotalSeconds) seconds" -ForegroundColor Green }

Write-Host "`n🎉 Examples completed!" -ForegroundColor Green
Write-Host "📚 For more options, run: nullscan --help" -ForegroundColor Cyan
Write-Host "🌐 Network range scanning examples:" -ForegroundColor Cyan
Write-Host "  - Small network: nullscan --target 192.168.1.0/28 --top100 --max-hosts 4" -ForegroundColor Gray
Write-Host "  - Large network: nullscan --target 10.0.0.0/16 --top1000 --max-hosts 16 --format json" -ForegroundColor Gray
Write-Host "  - Fast discovery: nullscan --target 172.16.0.0/24 --ports 22,80,443 --max-hosts 8" -ForegroundColor Gray to use NullScan including network range scanning

Write-Host "🔍 NullScan Usage Examples" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

# Build the project first
Write-Host "`n📦 Building NullScan..." -ForegroundColor Yellow
cargo build --release

# Set up alias for easier usage
Write-Host "`n⚙️ Setting up PowerShell alias..." -ForegroundColor Yellow
Set-Alias nullscan "$PWD\target\release\nullscan.exe"
Write-Host "✅ Alias 'nullscan' configured for this session" -ForegroundColor Green

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
& nullscan --target 127.0.0.1 --top100

Write-Host "`n" + "="*80

# Example 2: Network range scan (CIDR)
Write-Host "`n🎯 Example 2: Network range scan with CIDR notation" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 127.0.0.1/31 --ports 80,443 --verbose"
& nullscan --target 127.0.0.1/31 --ports 80,443 --verbose

Write-Host "`n" + "="*80

# Example 3: Custom ports with banners
Write-Host "`n🎯 Example 3: Scan specific ports with banner grabbing" -ForegroundColor Magenta
Write-Host "Command: nullscan --target google.com --ports 80,443 --banners --format json"
& nullscan --target google.com --ports 80,443 --banners --format json

Write-Host "`n" + "="*80

# Example 4: Range scan with CSV output
Write-Host "`n🎯 Example 4: Port range scan with CSV export" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv"
& nullscan --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv

if (Test-Path "localhost_range.csv") {
    Write-Host "`n📄 Generated CSV file:" -ForegroundColor Green
    Get-Content "localhost_range.csv" | Write-Host
}

Write-Host "`n" + "="*80

# Example 5: Network scanning demo (limited range)
Write-Host "`n🎯 Example 5: Small network range scan" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 192.168.1.1/30 --ports 80,443 --timeout 1000 --verbose"
Write-Host "(Scanning a /30 network - 2 hosts)"
& nullscan --target 192.168.1.1/30 --ports 80,443 --timeout 1000 --verbose

Write-Host "`n🎉 Examples completed!" -ForegroundColor Green
Write-Host "📚 For more options, run: nullscan --help" -ForegroundColor Cyan
Write-Host "� Network range scanning examples:" -ForegroundColor Cyan
Write-Host "  - Local subnet: nullscan --target 192.168.1.0/24 --top100" -ForegroundColor Gray
Write-Host "  - Corporate range: nullscan --target 10.0.0.0/16 --top1000 --format json" -ForegroundColor Gray
Write-Host "  - Small range: nullscan --target 172.16.0.0/28 --ports 22,80,443" -ForegroundColor Gray
