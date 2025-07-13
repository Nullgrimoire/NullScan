#!/usr/bin/env python3
"""
NullScan Usage Examples
Cross-platform demo script for NullScan features
Works on Windows, Linux, macOS, and other platforms with Python 3.6+
"""

import os
import sys
import subprocess
import platform
import time
from pathlib import Path

# Check if we're in CI mode
CI_MODE = os.environ.get('CI_MODE', '0') == '1'

# ANSI color codes for cross-platform colored output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    CYAN = '\033[0;36m'
    GRAY = '\033[0;37m'
    NC = '\033[0m'  # No Color

    @classmethod
    def disable_on_windows_cmd(cls):
        """Disable colors on Windows CMD (but keep them for PowerShell/Windows Terminal)"""
        if platform.system() == 'Windows' and 'WT_SESSION' not in os.environ and 'TERM' not in os.environ:
            for attr in dir(cls):
                if not attr.startswith('_') and attr != 'disable_on_windows_cmd':
                    setattr(cls, attr, '')

# Initialize colors
Colors.disable_on_windows_cmd()

def print_colored(text, color=Colors.NC):
    """Print colored text"""
    print(f"{color}{text}{Colors.NC}")

def print_header(text):
    """Print a header with formatting"""
    print_colored(f"\n🎯 {text}", Colors.MAGENTA)

def print_command(cmd):
    """Print a command being executed"""
    print_colored(f"Command: {cmd}", Colors.GRAY)

def run_command(cmd, show_output=True, timeout=60):
    """Run a command and optionally show its output"""
    try:
        if show_output:
            result = subprocess.run(cmd, shell=True, timeout=timeout)
            return result.returncode == 0
        else:
            result = subprocess.run(cmd, shell=True, capture_output=True, timeout=timeout)
            return result.returncode == 0, result.stdout.decode(), result.stderr.decode()
    except subprocess.TimeoutExpired:
        print_colored("❌ Command timed out", Colors.RED)
        return False
    except Exception as e:
        print_colored(f"❌ Error running command: {e}", Colors.RED)
        return False

def get_nullscan_binary():
    """Get the correct nullscan binary path for the current platform"""
    if platform.system() == 'Windows':
        return '.\\target\\release\\nullscan.exe'
    else:
        return './target/release/nullscan'

def main():
    """Main demo function"""
    print_colored("🔍 NullScan Usage Examples", Colors.CYAN)
    print_colored("=========================", Colors.CYAN)
    print_colored(f"Platform: {platform.system()} {platform.release()}", Colors.BLUE)
    print_colored(f"Python: {sys.version.split()[0]}", Colors.BLUE)

    # Build the project first
    print_colored("\n📦 Building NullScan...", Colors.YELLOW)
    if not run_command("cargo build --release"):
        print_colored("❌ Build failed!", Colors.RED)
        sys.exit(1)

    print_colored("\n✅ Build successful!", Colors.GREEN)

    # Get the correct binary path
    nullscan = get_nullscan_binary()

    # Verify binary exists
    if not Path(nullscan).exists():
        print_colored(f"❌ Binary not found at: {nullscan}", Colors.RED)
        sys.exit(1)

    print_colored(f"\n🔧 Using binary: {nullscan}", Colors.YELLOW)

    # Setup instructions
    print_colored("\n💡 Setup Tips:", Colors.CYAN)
    if platform.system() == 'Windows':
        print_colored("  PowerShell: Set-Alias nullscan \".\\target\\release\\nullscan.exe\"", Colors.GRAY)
        print_colored("  CMD: doskey nullscan=.\\target\\release\\nullscan.exe $*", Colors.GRAY)
    else:
        print_colored(f"  Bash/Zsh: alias nullscan='{Path(nullscan).absolute()}'", Colors.GRAY)
        print_colored(f"  Fish: alias nullscan '{Path(nullscan).absolute()}'", Colors.GRAY)

    separator = "=" * 80

    # Example 1: Basic scan
    print_header("Example 1: Basic scan of localhost with top 100 ports")
    cmd = f"{nullscan} --target 127.0.0.1 --top100"
    print_command(cmd)
    if CI_MODE:
        print_colored("(CI Mode: Skipping actual scan, showing help instead)", Colors.YELLOW)
        run_command(f"{nullscan} --help | head -10", show_output=False)
    else:
        run_command(cmd)
    print(separator)

    # Example 2: Network range scan
    print_header("Example 2: Network range scan with CIDR notation")
    cmd = f"{nullscan} --target 127.0.0.1/31 --ports 80,443 --verbose"
    print_command(cmd)
    if CI_MODE:
        print_colored("(CI Mode: Showing version instead)", Colors.YELLOW)
        run_command(f"{nullscan} --version")
    else:
        run_command(cmd)
    print(separator)

    # Example 3: Ping sweep demonstration
    print_header("Example 3: Ping sweep for efficient network scanning")
    cmd = f"{nullscan} --target 192.168.1.0/30 --ping-sweep --ports 22,80,443 --verbose"
    print_command(cmd)
    print_colored("(This will ping sweep first to find live hosts, then scan only reachable ones)", Colors.GRAY)
    if CI_MODE:
        print_colored("(CI Mode: Showing ping sweep feature info)", Colors.YELLOW)
        print("Ping sweep optimizes scanning by testing host availability first")
    else:
        run_command(cmd)
    print(separator)

    # Example 4: Multiple targets
    print_header("Example 4: Multiple targets with ping sweep")
    cmd = f'{nullscan} --target "8.8.8.8,8.8.4.4,1.1.1.1" --ping-sweep --ports 53,80,443'
    print_command(cmd)
    if CI_MODE:
        print_colored("(CI Mode: Showing multiple target syntax)", Colors.YELLOW)
        print('Multiple targets can be specified as: --target "host1,host2,host3"')
    else:
        run_command(cmd)
    print(separator)

    # Example 5: JSON export
    print_header("Example 5: Banner grabbing with JSON export")
    json_file = "google_scan.json"
    cmd = f"{nullscan} --target google.com --ports 80,443 --banners --format json --output {json_file}"
    print_command(cmd)
    if CI_MODE:
        print_colored("(CI Mode: Showing JSON format example)", Colors.YELLOW)
        sample_json = '{"target":"example.com","ports":[{"port":80,"state":"open","service":"http","banner":"Server: nginx/1.18.0"}]}'
        print(sample_json)
        with open(json_file, 'w') as f:
            f.write(sample_json)
    else:
        run_command(cmd)

    if Path(json_file).exists():
        print_colored(f"\n📄 Generated JSON file:", Colors.GREEN)
        with open(json_file, 'r') as f:
            print(f.read())
    print(separator)

    # Example 6: CSV export
    print_header("Example 6: Port range scan with CSV export")
    csv_file = "localhost_range.csv"
    cmd = f"{nullscan} --target 127.0.0.1 --ports 130-140 --format csv --output {csv_file}"
    print_command(cmd)
    if CI_MODE:
        print_colored("(CI Mode: Showing CSV format example)", Colors.YELLOW)
        sample_csv = "host,port,state,service,banner\n127.0.0.1,135,closed,msrpc,\n127.0.0.1,139,closed,netbios-ssn,"
        print(sample_csv)
        with open(csv_file, 'w') as f:
            f.write(sample_csv)
    else:
        run_command(cmd)

    if Path(csv_file).exists():
        print_colored(f"\n📄 Generated CSV file:", Colors.GREEN)
        with open(csv_file, 'r') as f:
            print(f.read())
    print(separator)

    # Example 7: Performance comparison
    print_header("Example 7: Performance comparison (Sequential vs Parallel)")

    if CI_MODE:
        print_colored("(CI Mode: Showing performance comparison concept)", Colors.YELLOW)
        print("Sequential scanning (--max-hosts 1): One host at a time")
        print("Parallel scanning (--max-hosts 2+): Multiple hosts simultaneously")
        print("Performance benefits scale with network size and available resources")
    else:
        # Sequential scan
        print_colored("Testing sequential scanning (--max-hosts 1):", Colors.BLUE)
        cmd_seq = f"{nullscan} --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 1"
        print_command(cmd_seq)
        start_time = time.time()
        run_command(cmd_seq, show_output=False)
        seq_time = time.time() - start_time
        print_colored(f"Sequential time: {seq_time:.2f} seconds", Colors.CYAN)

        # Parallel scan
        print_colored("\nTesting parallel scanning (--max-hosts 2):", Colors.BLUE)
        cmd_par = f"{nullscan} --target 127.0.0.1/30 --ports 80,443 --timeout 1000 --max-hosts 2"
        print_command(cmd_par)
        start_time = time.time()
        run_command(cmd_par, show_output=False)
        par_time = time.time() - start_time
        print_colored(f"Parallel time: {par_time:.2f} seconds", Colors.GREEN)

        if par_time < seq_time:
            improvement = ((seq_time - par_time) / seq_time) * 100
            print_colored(f"🚀 Parallel scanning was {improvement:.1f}% faster!", Colors.GREEN)

    print(separator)

    # Completion
    print_colored("\n🎉 Examples completed!", Colors.GREEN)
    print_colored("📚 For more options, run: nullscan --help", Colors.CYAN)
    print_colored("🌐 Advanced usage examples:", Colors.CYAN)
    print_colored("  - Large network with ping sweep: nullscan --target 10.0.0.0/24 --ping-sweep --top100 --max-hosts 10", Colors.GRAY)
    print_colored("  - Multiple targets: nullscan --target \"8.8.8.8,8.8.4.4,1.1.1.1\" --ping-sweep --ports 53,80,443", Colors.GRAY)
    print_colored("  - Enterprise scan: nullscan --target 172.16.0.0/16 --ping-sweep --top1000 --max-hosts 20 --format json", Colors.GRAY)
    print_colored("  - Parallel scanning: nullscan --target 192.168.1.0/24 --top100 --max-hosts 8", Colors.GRAY)

    # Cleanup
    print_colored("\n🧹 Cleaning up demo files...", Colors.YELLOW)
    for file in [json_file, csv_file]:
        try:
            Path(file).unlink(missing_ok=True)
        except:
            pass
    print_colored("✅ Cleanup completed!", Colors.GREEN)

    print_colored("\nHappy scanning! 🔍✨", Colors.GREEN)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print_colored("\n\n❌ Demo interrupted by user", Colors.YELLOW)
        sys.exit(1)
    except Exception as e:
        print_colored(f"\n❌ Demo failed with error: {e}", Colors.RED)
        sys.exit(1)
