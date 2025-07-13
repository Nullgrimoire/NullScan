#!/usr/bin/env pwsh

# NullScan Usage Examples
# Demonstrate various feWrite-Host "`n🎉 Examples completed!" -ForegroundColor Green
Write-Host "📚 For more options, run: nullscan --help" -ForegroundColor Cyan
Write-Host "🌐 Advanced usage examples:" -ForegroundColor Cyan
Write-Host "  - Large network with ping sweep: nullscan --target 10.0.0.0/24 --ping-sweep --top100 --max-hosts 10" -ForegroundColor Gray
Write-Host "  - Multiple targets: nullscan --target `"8.8.8.8,8.8.4.4,1.1.1.1`" --ping-sweep --ports 53,80,443" -ForegroundColor Gray
Write-Host "  - Enterprise scan: nullscan --target 172.16.0.0/16 --ping-sweep --top1000 --max-hosts 20 --format json" -ForegroundColor Gray
Write-Host "  - Parallel scanning: nullscan --target 192.168.1.0/24 --top100 --max-hosts 8" -ForegroundColor Gray

# Cleanup demo files
Write-Host "`n🧹 Cleaning up demo files..." -ForegroundColor Yellow
Remove-Item -Path "localhost_range.csv" -ErrorAction SilentlyContinue
Write-Host "✅ Cleanup completed!" -ForegroundColor Green including ping sweep and parallel scanning

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
& nullscan --target 127.0.0.1 --top100

Write-Host "`n" + "="*80

# Example 2: Network range scan (CIDR)
Write-Host "`n🎯 Example 2: Network range scan with CIDR notation" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 127.0.0.1/31 --ports 80,443 --verbose"
& nullscan --target 127.0.0.1/31 --ports 80,443 --verbose

Write-Host "`n" + "="*80

# Example 2.5: Ping sweep demonstration
Write-Host "`n🎯 Example 2.5: Ping sweep for efficient network scanning" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose"
Write-Host "(This will ping sweep first to find live hosts, then scan only reachable ones)"
& nullscan --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose

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
