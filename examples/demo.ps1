#!/usr/bin/env pwsh

# 🔍 NullScan Professional Demo Script
# Showcase all major features for content creators and cybersecurity professionals
# Demonstrates LUDICROUS SPEED, vulnerability assessment, and professional reporting

# Check if we're in CI mode
$CI_MODE = $env:CI_MODE -eq "1"

Write-Host "🔍 NullScan Professional Demo Suite" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Showcasing professional-grade network scanning capabilities" -ForegroundColor Gray

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

# ==============================================================================
# DEMO 1: LUDICROUS SPEED Mode - The Performance Showcase
# ==============================================================================
Write-Host "⚡ DEMO 1: LUDICROUS SPEED Mode - Maximum Performance" -ForegroundColor Magenta
Write-Host "======================================================" -ForegroundColor Magenta
Write-Host "Showcasing auto-optimized fast mode with CPU detection"
Write-Host "Command: nullscan --target 127.0.0.1 --fast-mode --top100 --verbose"
Write-Host ""
if ($CI_MODE) {
    Write-Host "(CI Mode: Showing fast mode capabilities)" -ForegroundColor Yellow
    Write-Host "Fast Mode Features:"
    Write-Host "• Auto CPU detection (cores × 150 concurrency)"
    Write-Host "• 95ms timeout for rapid scanning"
    Write-Host "• Batched processing for efficiency"
    Write-Host "• Competitive with industry-standard tools"
} else {
    Write-Host "🚀 Watch the speed - auto-detects CPU cores and optimizes concurrency!" -ForegroundColor Yellow
    Measure-Command { & nullscan --target 127.0.0.1 --fast-mode --top100 --verbose } | ForEach-Object {
        Write-Host "`n⏱️  Fast Mode completed in: $($_.TotalMilliseconds)ms" -ForegroundColor Green
    }
}

Write-Host "`n" + "="*80

# ==============================================================================
# DEMO 2: Service Detection & Banner Grabbing
# ==============================================================================
Write-Host "`n🔍 DEMO 2: Intelligent Service Detection" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "Protocol-specific probes for accurate service identification"
Write-Host "Command: nullscan --target 8.8.8.8 --ports 53,80,443 --banners --verbose"
Write-Host ""
if ($CI_MODE) {
    Write-Host "(CI Mode: Showing banner grabbing capabilities)" -ForegroundColor Yellow
    Write-Host "Service Detection Features:"
    Write-Host "• SSH version handshake"
    Write-Host "• HTTP/HTTPS server detection"
    Write-Host "• Database protocol probing"
    Write-Host "• Confidence scoring system"
} else {
    Write-Host "🎯 Watch intelligent protocol detection in action!" -ForegroundColor Yellow
    & nullscan --target 8.8.8.8 --ports 53,80,443 --banners --verbose
}

Write-Host "`n" + "="*80

# ==============================================================================
# DEMO 3: Vulnerability Assessment
# ==============================================================================
Write-Host "`n🛡️ DEMO 3: Offline Vulnerability Assessment" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "Real-time CVE detection with severity classification"
Write-Host "Command: nullscan --target 127.0.0.1 --top100 --banners --vuln-check"
Write-Host ""
if ($CI_MODE) {
    Write-Host "(CI Mode: Showing vulnerability features)" -ForegroundColor Yellow
    Write-Host "Vulnerability Assessment Features:"
    Write-Host "• Offline CVE database (12+ patterns)"
    Write-Host "• CVSS severity scoring"
    Write-Host "• Pattern matching for version detection"
    Write-Host "• Real-time vulnerability display"
} else {
    Write-Host "🔒 Demonstrating integrated security assessment!" -ForegroundColor Yellow
    & nullscan --target 127.0.0.1 --top100 --banners --vuln-check
}

Write-Host "`n" + "="*80

# ==============================================================================
# DEMO 4: Professional Reporting - HTML Export
# ==============================================================================
Write-Host "`n📊 DEMO 4: Professional HTML Reports" -ForegroundColor Magenta
Write-Host "====================================" -ForegroundColor Magenta
Write-Host "Interactive HTML reports for penetration testing documentation"
Write-Host "Command: nullscan --target 127.0.0.1 --top100 --banners --format html --output demo_report.html"
Write-Host ""
if ($CI_MODE) {
    Write-Host "(CI Mode: Showing HTML report features)" -ForegroundColor Yellow
    Write-Host "HTML Report Features:"
    Write-Host "• Interactive sortable tables"
    Write-Host "• Professional styling"
    Write-Host "• Copy-to-clipboard functionality"
    Write-Host "• Mobile-friendly responsive design"
    Write-Host "• IP-grouped multi-host results"
} else {
    Write-Host "📝 Generating professional HTML report..." -ForegroundColor Yellow
    & nullscan --target 127.0.0.1 --top100 --banners --format html --output demo_report.html
    if (Test-Path "demo_report.html") {
        Write-Host "✅ HTML report generated: demo_report.html" -ForegroundColor Green
        Write-Host "   Open in browser to see interactive features!" -ForegroundColor Cyan
    }
}

Write-Host "`n" + "="*80

# ==============================================================================
# DEMO 5: Network Range Scanning with Ping Sweep
# ==============================================================================
Write-Host "`n� DEMO 5: Efficient Network Range Scanning" -ForegroundColor Magenta
Write-Host "===========================================" -ForegroundColor Magenta
Write-Host "115x faster than sequential scanning with ping sweep optimization"
Write-Host "Command: nullscan --target 127.0.0.1/30 --ping-sweep --top100 --max-hosts 4 --verbose"
Write-Host ""
if ($CI_MODE) {
    Write-Host "(CI Mode: Showing ping sweep benefits)" -ForegroundColor Yellow
    Write-Host "Ping Sweep Optimization:"
    Write-Host "• TCP-based host detection (not ICMP)"
    Write-Host "• Parallel host discovery"
    Write-Host "• Skip unreachable hosts"
    Write-Host "• 115x performance improvement"
} else {
    Write-Host "🏓 Watch efficient network discovery in action!" -ForegroundColor Yellow
    Measure-Command { & nullscan --target 127.0.0.1/30 --ping-sweep --top100 --max-hosts 4 --verbose } | ForEach-Object {
        Write-Host "`n⏱️  Network scan completed in: $($_.TotalMilliseconds)ms" -ForegroundColor Green
    }
}

Write-Host "`n" + "="*80

# ==============================================================================
# DEMO 6: Multi-Format Export Showcase
# ==============================================================================
Write-Host "`n📋 DEMO 6: Multi-Format Export Capabilities" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "Professional export formats for different use cases"
Write-Host ""

$formats = @("json", "csv", "markdown")
foreach ($format in $formats) {
    Write-Host "Generating $format report..." -ForegroundColor Yellow
    $outputFile = "demo_output.$format"

    if ($CI_MODE) {
        Write-Host "(CI Mode: Showing $format format capabilities)" -ForegroundColor Yellow
        switch ($format) {
            "json" { Write-Host "• Machine-readable data exchange" }
            "csv" { Write-Host "• Spreadsheet compatibility" }
            "markdown" { Write-Host "• Documentation and reports" }
        }
    } else {
        & nullscan --target 127.0.0.1 --ports 80,443 --format $format --output $outputFile --quiet
        if (Test-Path $outputFile) {
            Write-Host "✅ Generated: $outputFile" -ForegroundColor Green
        }
    }
}

Write-Host "`n" + "="*80

# ==============================================================================
# DEMO SUMMARY & NEXT STEPS
# ==============================================================================
Write-Host "`n🎯 Demo Summary - NullScan Professional Features" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ LUDICROUS SPEED Mode - Auto CPU optimization" -ForegroundColor Green
Write-Host "✅ Service Detection - Protocol-specific probing" -ForegroundColor Green
Write-Host "✅ Vulnerability Assessment - Offline CVE database" -ForegroundColor Green
Write-Host "✅ Professional Reports - Interactive HTML output" -ForegroundColor Green
Write-Host "✅ Network Optimization - 115x faster ping sweep" -ForegroundColor Green
Write-Host "✅ Multi-Format Export - JSON, CSV, HTML, Markdown" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Ready for:" -ForegroundColor Yellow
Write-Host "   • Penetration Testing" -ForegroundColor White
Write-Host "   • Network Administration" -ForegroundColor White
Write-Host "   • Security Assessments" -ForegroundColor White
Write-Host "   • Automation & CI/CD" -ForegroundColor White
Write-Host ""
Write-Host "📚 For detailed documentation:" -ForegroundColor Cyan
Write-Host "   • Performance Benchmarks: docs/benchmarks.md" -ForegroundColor Gray
Write-Host "   • Fast Mode Guide: docs/fast-mode-deep-dive.md" -ForegroundColor Gray
Write-Host "   • Banner Grabbing: docs/banner-grabbing-deep-dive.md" -ForegroundColor Gray
Write-Host ""
Write-Host "🎬 Content Creator Ready!" -ForegroundColor Magenta
Write-Host "   Professional-grade tool with competitive performance" -ForegroundColor White

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
