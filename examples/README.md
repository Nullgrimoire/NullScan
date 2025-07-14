# 📋 NullScan Examples & Content Creator Kit

This directory contains professional demo scripts and content creator resources showcasing NullScan's capabilities across different platforms and use cases.

## 🎬 Content Creator Kit

### **📁 `content-creator-kit/`**
Professional resources for YouTube videos, technical blogs, and demonstrations:

- **`benchmark-comparison.ps1`** - Automated performance benchmarks (Windows)
- **`benchmark-comparison.sh`** - Automated performance benchmarks (Linux/macOS)
- **`demo-targets.txt`** - Safe targets for demonstrations
- **`sample-outputs/`** - Example reports for B-roll footage
- **`README.md`** - Complete content creator guide

**Perfect for**: Technical content creators, cybersecurity channels, performance comparisons

## 🌐 Cross-Platform Demo Scripts

### Windows

#### PowerShell (`demo.ps1`)

- **Best for**: Windows PowerShell 5.1+ and PowerShell Core 7+
- **Features**: Professional demo suite with 6 comprehensive demonstrations
- **Showcases**: LUDICROUS SPEED mode, vulnerability assessment, HTML reports
- **Usage**:

  ```powershell
  .\examples\demo.ps1
  ```

#### Command Prompt (`demo.bat`)

- **Best for**: Windows Command Prompt (CMD)
- **Features**: Basic functionality with Windows-specific commands
- **Usage**:

  ```cmd
  examples\demo.bat
  ```

### Linux & macOS

#### Bash (`demo.sh`)

- **Best for**: Most Linux distributions and macOS with Bash
- **Features**: Full ANSI color support, performance timing
- **Usage**:

  ```bash
  ./examples/demo.sh
  ```

- **Requirements**: Bash 4.0+

#### Fish Shell (`demo.fish`)

- **Best for**: Fish shell users
- **Features**: Fish-specific syntax and colored output
- **Usage**:

  ```fish
  ./examples/demo.fish
  ```

- **Requirements**: Fish 3.0+

### Universal

#### Python (`demo.py`)

- **Best for**: Any platform with Python 3.6+
- **Features**: Cross-platform compatibility, intelligent color detection
- **Usage**:

  ```bash
  # Linux/macOS
  python3 examples/demo.py

  # Windows
  python examples\demo.py
  ```

- **Requirements**: Python 3.6+

## 🎯 What Each Demo Covers

All demo scripts showcase the following NullScan features:

1. **Basic Port Scanning**
   - Single host with top 100 ports
   - Custom port ranges

2. **Network Range Scanning**
   - CIDR notation support
   - Parallel vs sequential host scanning

3. **Ping Sweep Feature**
   - Pre-scan host discovery
   - Performance optimization for large networks

4. **Multiple Target Support**
   - Comma-separated IP addresses
   - Mixed target types

5. **Output Formats**
   - JSON export with banner grabbing
   - CSV export for data analysis
   - Markdown output (default)

6. **Performance Testing**
   - Sequential vs parallel scanning comparison
   - Timing measurements

7. **Advanced Features**
   - Banner grabbing
   - Verbose logging
   - Custom timeouts and concurrency

## 🚀 Quick Start

Choose the demo script that matches your platform and shell:

```bash
# Clone and build
git clone https://github.com/nullscan/nullscan.git
cd nullscan
cargo build --release

# Run appropriate demo
./examples/demo.sh        # Linux/macOS Bash
./examples/demo.fish      # Fish shell
./examples/demo.ps1       # Windows PowerShell
examples/demo.bat         # Windows CMD
python3 examples/demo.py  # Any platform with Python
```

## 📊 Expected Output

Each demo will:

1. Build NullScan in release mode
2. Run through 6-7 example scenarios
3. Show different output formats
4. Demonstrate performance features
5. Clean up generated files
6. Display usage tips and advanced examples

## 🔧 Customization

Feel free to modify these scripts for your specific use cases:

- **Add your own targets**: Replace example IPs with your network ranges
- **Adjust port lists**: Modify port ranges for your environment
- **Change output formats**: Test different export options
- **Add timing tests**: Include your own performance benchmarks

## 💡 Shell Setup Tips

### Permanent Aliases

**Bash/Zsh** (Linux/macOS):

```bash
echo "alias nullscan='$(pwd)/target/release/nullscan'" >> ~/.bashrc
# or for zsh: ~/.zshrc
```

**Fish**:

```fish
echo "alias nullscan '$(pwd)/target/release/nullscan'" >> ~/.config/fish/config.fish
```

**PowerShell**:

```powershell
Add-Content $PROFILE "Set-Alias nullscan '$PWD\target\release\nullscan.exe'"
```

**CMD**:

```cmd
doskey nullscan=%CD%\target\release\nullscan.exe $*
```

### PATH Installation

For system-wide access, copy the binary to a directory in your PATH:

**Linux/macOS**:

```bash
sudo cp target/release/nullscan /usr/local/bin/
```

**Windows**:

```cmd
copy target\release\nullscan.exe C:\Windows\System32\
```

## 🛠️ Troubleshooting

### Build Issues

- Ensure Rust is installed: `rustup --version`
- Update Rust: `rustup update`
- Clean and rebuild: `cargo clean && cargo build --release`

### Permission Issues (Linux/macOS)

- Make scripts executable: `chmod +x examples/*.sh examples/*.py examples/*.fish`
- Run with explicit interpreter: `bash examples/demo.sh`

### Network Connectivity

- Some examples require internet access (google.com, DNS servers)
- Adjust timeout values for slow networks: `--timeout 5000`
- Use local targets for offline testing: `127.0.0.1`, `localhost`

## 📚 Additional Resources

- **Main Documentation**: [../README.md](../README.md)
- **Contributing Guide**: [../CONTRIBUTING.md](../CONTRIBUTING.md)
- **Security Policy**: [../SECURITY.md](../SECURITY.md)
- **Help Command**: `nullscan --help`

---

**Happy Scanning!** 🔍✨
