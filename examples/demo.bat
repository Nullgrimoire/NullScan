@echo off
REM NullScan Usage Examples
REM Demonstrate various features including ping sweep and parallel scanning
REM For Windows Command Prompt (CMD)

setlocal enabledelayedexpansion

echo.
echo 🔍 NullScan Usage Examples
echo =========================
echo Platform: Windows (Command Prompt)

REM Build the project first
echo.
echo 📦 Building NullScan...
cargo build --release

if !errorlevel! neq 0 (
    echo ❌ Build failed!
    pause
    exit /b 1
)

echo.
echo ✅ Build successful!

REM Set up local variable for easier usage
set "nullscan=.\target\release\nullscan.exe"

echo.
echo 💡 Setup Tip: Add this to your PATH or create a batch file in your PATH:
echo    doskey nullscan=%CD%\target\release\nullscan.exe $*

echo.
echo ================================================================================

REM Example 1: Basic scan
echo.
echo 🎯 Example 1: Basic scan of localhost with top 100 ports
echo Command: %nullscan% --target 127.0.0.1 --top100
%nullscan% --target 127.0.0.1 --top100

echo.
echo ================================================================================

REM Example 2: Network range scan
echo.
echo 🎯 Example 2: Network range scan with CIDR notation
echo Command: %nullscan% --target 127.0.0.1/31 --ports 80,443 --verbose
%nullscan% --target 127.0.0.1/31 --ports 80,443 --verbose

echo.
echo ================================================================================

REM Example 3: Ping sweep
echo.
echo 🎯 Example 3: Ping sweep for efficient network scanning
echo Command: %nullscan% --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose
echo (This will ping sweep first to find live hosts, then scan only reachable ones)
%nullscan% --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose

echo.
echo ================================================================================

REM Example 4: Multiple targets
echo.
echo 🎯 Example 4: Multiple targets with ping sweep
echo Command: %nullscan% --target "8.8.8.8,8.8.4.4,1.1.1.1" --ping-sweep --ports 53,80,443
%nullscan% --target "8.8.8.8,8.8.4.4,1.1.1.1" --ping-sweep --ports 53,80,443

echo.
echo ================================================================================

REM Example 5: JSON export
echo.
echo 🎯 Example 5: Banner grabbing with JSON export
echo Command: %nullscan% --target google.com --ports 80,443 --banners --format json --output google_scan.json
%nullscan% --target google.com --ports 80,443 --banners --format json --output google_scan.json

if exist google_scan.json (
    echo.
    echo 📄 Generated JSON file:
    type google_scan.json
)

echo.
echo ================================================================================

REM Example 6: CSV export
echo.
echo 🎯 Example 6: Port range scan with CSV export
echo Command: %nullscan% --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv
%nullscan% --target 127.0.0.1 --ports 130-140 --format csv --output localhost_range.csv

if exist localhost_range.csv (
    echo.
    echo 📄 Generated CSV file:
    type localhost_range.csv
)

echo.
echo ================================================================================

REM Example 7: Performance comparison
echo.
echo 🎯 Example 7: Parallel vs Sequential Host Scanning
echo Testing sequential scanning (--max-hosts 1):
echo Command: %nullscan% --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 1
%nullscan% --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 1 >nul 2>&1

echo.
echo Testing parallel scanning (--max-hosts 2):
echo Command: %nullscan% --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 2
%nullscan% --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 2 >nul 2>&1

echo.
echo ================================================================================

echo.
echo 🎉 Examples completed!
echo 📚 For more options, run: %nullscan% --help
echo 🌐 Advanced usage examples:
echo   - Large network with ping sweep: %nullscan% --target 10.0.0.0/24 --ping-sweep --top100 --max-hosts 10
echo   - Multiple targets: %nullscan% --target "8.8.8.8,8.8.4.4,1.1.1.1" --ping-sweep --ports 53,80,443
echo   - Enterprise scan: %nullscan% --target 172.16.0.0/16 --ping-sweep --top1000 --max-hosts 20 --format json
echo   - Parallel scanning: %nullscan% --target 192.168.1.0/24 --top100 --max-hosts 8

REM Cleanup demo files
echo.
echo 🧹 Cleaning up demo files...
if exist google_scan.json del google_scan.json >nul 2>&1
if exist localhost_range.csv del localhost_range.csv >nul 2>&1
echo ✅ Cleanup completed!

echo.
echo Happy scanning! 🔍✨
echo.
pause
