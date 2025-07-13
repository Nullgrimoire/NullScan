#!/usr/bin/env pwsh

# NullScan Usage Examples
# T# Example 4: Fast scan with high concurrency
Write-Host "`n🎯 Example 4: Fast scan with high concurrency" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 127.0.0.1 --ports 1-1000 --concurrency 500 --timeout 1000"
Write-Host "(This would scan ports 1-1000 very quickly - skipping for demo)"

Write-Host "`n" + "="*80

# Example 5: Verbose scan for debugging
Write-Host "`n🎯 Example 5: Verbose scan for debugging" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 127.0.0.1 --ports 22,80,135,443,445 --verbose"
& nullscan --target 127.0.0.1 --ports 22, 80, 135, 443, 445 --verbose

Write-Host "`n🎉 Examples completed!" -ForegroundColor Green
Write-Host "📚 For more options, run: nullscan --help" -ForegroundColor Cyanonstrates various ways to use NullScan

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

# Example 2: Custom ports with banners
Write-Host "`n🎯 Example 2: Scan specific ports with banner grabbing" -ForegroundColor Magenta
Write-Host "Command: nullscan --target google.com --ports 80,443 --banners --format json"
& nullscan --target google.com --ports 80, 443 --banners --format json

Write-Host "`n" + "="*80

# Example 3: Range scan with CSV output
Write-Host "`n🎯 Example 3: Port range scan with CSV export" -ForegroundColor Magenta
Write-Host "Command: nullscan --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv"
& nullscan --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv

if (Test-Path "localhost_range.csv") {
    Write-Host "`n📄 Generated CSV file:" -ForegroundColor Green
    Get-Content "localhost_range.csv" | Write-Host
}

Write-Host "`n" + "="*80

# Example 4: Fast scan with high concurrency
Write-Host "`n🎯 Example 4: Fast scan with high concurrency" -ForegroundColor Magenta
Write-Host "Command: $nullscan --target 127.0.0.1 --ports 1-1000 --concurrency 500 --timeout 1000"
Write-Host "(This would scan ports 1-1000 very quickly - skipping for demo)"

Write-Host "`n" + "="*80

# Example 5: Verbose scan for debugging
Write-Host "`n🎯 Example 5: Verbose scan for debugging" -ForegroundColor Magenta
Write-Host "Command: $nullscan --target 127.0.0.1 --ports 22,80,135,443,445 --verbose"
& $nullscan --target 127.0.0.1 --ports 22, 80, 135, 443, 445 --verbose

Write-Host "`n🎉 Examples completed!" -ForegroundColor Green
Write-Host "📚 For more options, run: $nullscan --help" -ForegroundColor Cyan
