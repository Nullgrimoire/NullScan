# 🚀 Release Process

This document outlines the automated release process for NullScan, which builds and publishes prebuilt binaries for all major platforms.

## 🎯 Overview

NullScan uses a comprehensive GitHub Actions workflow to automatically build, test, and release binaries for:

- **Linux**: x86_64, ARM64, and musl variants
- **Windows**: 64-bit and 32-bit executables  
- **macOS**: Intel and Apple Silicon binaries

## 📋 Release Checklist

### 1. Prepare Release
```bash
# Use the automated preparation script
./scripts/prepare-release.sh 1.2.0

# Or manually:
# - Update version in Cargo.toml
# - Run tests: cargo test --all-features
# - Run clippy: cargo clippy -- -D warnings
# - Run security audit: cargo audit
# - Create git tag: git tag v1.2.0
```

### 2. Publish Release
```bash
# Push changes and tag
git push origin master
git push origin v1.2.0

# Create GitHub release
# Go to: https://github.com/Nullgrimoire/NullScan/releases/new
# Or use GitHub CLI: gh release create v1.2.0
```

### 3. Automated Workflow
The release workflow automatically:
- ✅ Builds binaries for all platforms
- ✅ Strips and optimizes binaries
- ✅ Creates platform-specific archives
- ✅ Generates SHA256 checksums
- ✅ Creates installation scripts
- ✅ Publishes comprehensive release notes
- ✅ Uploads all assets to GitHub release

## 🏗️ Build Matrix

| Platform | Target | Binary | Archive | Notes |
|----------|--------|--------|---------|-------|
| Linux x64 | `x86_64-unknown-linux-gnu` | `nullscan` | `.tar.gz` | Standard glibc |
| Linux x64 (static) | `x86_64-unknown-linux-musl` | `nullscan` | `.tar.gz` | No dependencies |
| Linux ARM64 | `aarch64-unknown-linux-gnu` | `nullscan` | `.tar.gz` | Raspberry Pi, ARM servers |
| Windows x64 | `x86_64-pc-windows-msvc` | `nullscan.exe` | `.zip` | Most common |
| Windows x32 | `i686-pc-windows-msvc` | `nullscan.exe` | `.zip` | Legacy systems |
| macOS Intel | `x86_64-apple-darwin` | `nullscan` | `.tar.gz` | Intel Macs |
| macOS ARM | `aarch64-apple-darwin` | `nullscan` | `.tar.gz` | M1/M2/M3 Macs |

## 📦 Installation Methods

### One-Line Install
```bash
# Unix (Linux/macOS)
curl -sSL https://raw.githubusercontent.com/Nullgrimoire/NullScan/master/scripts/install.sh | bash

# Windows PowerShell
iwr -useb https://raw.githubusercontent.com/Nullgrimoire/NullScan/master/scripts/install.ps1 | iex
```

### Manual Download
1. Visit [releases page](https://github.com/Nullgrimoire/NullScan/releases/latest)
2. Download appropriate binary for your platform
3. Extract and run

### Package Managers (Future)
```bash
# Homebrew (planned)
brew install nullgrimoire/tap/nullscan

# Chocolatey (planned)  
choco install nullscan

# APT/YUM (planned)
curl -s https://packagecloud.io/install/repositories/nullgrimoire/nullscan/script.deb.sh | sudo bash
```

## 🔐 Security

### Binary Verification
All binaries include SHA256 checksums:
```bash
# Verify download integrity
sha256sum -c nullscan-*.sha256
```

### Reproducible Builds
- Fixed Rust toolchain versions
- Deterministic build flags
- Consistent cross-compilation environment

### Supply Chain Security
- GitHub Actions runners (trusted environment)
- Dependency pinning via Cargo.lock
- Regular security audits with cargo-audit
- Automated vulnerability scanning

## 🔧 Development

### Testing Release Process
```bash
# Test build for all platforms locally (requires cross-compilation setup)
cargo build --release --target x86_64-unknown-linux-gnu
cargo build --release --target x86_64-pc-windows-msvc
cargo build --release --target x86_64-apple-darwin

# Test installation scripts
./scripts/install.sh
./scripts/install.ps1
```

### Troubleshooting

**Cross-compilation Issues:**
- Ensure proper linkers are installed
- Check target-specific environment variables
- Verify Rust target is added: `rustup target add <target>`

**Release Workflow Failures:**
- Check GitHub Actions logs
- Verify all secrets and permissions are set
- Ensure tag format matches `v*` pattern

**Binary Issues:**
- Test on target platform before release
- Verify all dependencies are statically linked
- Check file permissions and executable flags

## 📊 Metrics

### Download Statistics
- Track via GitHub API: `/repos/Nullgrimoire/NullScan/releases`
- Monitor platform adoption rates
- Analyze geographic distribution

### Performance Targets
- Build time: < 10 minutes per platform
- Binary size: < 10MB compressed
- Installation time: < 30 seconds
- Zero external dependencies (musl builds)

## 🔄 Automation

### Scheduled Tasks
- Weekly dependency updates
- Monthly security audits  
- Quarterly cross-platform testing

### Webhooks & Integrations
- Discord/Slack notifications
- Package manager updates
- Documentation site rebuilds

## 📈 Future Enhancements

### Planned Features
- [ ] Package manager distributions
- [ ] Docker images
- [ ] Snap packages
- [ ] AppImage for Linux
- [ ] Windows Store package
- [ ] macOS App Store distribution

### Infrastructure
- [ ] CDN distribution for faster downloads
- [ ] Mirror sites for redundancy
- [ ] Torrent distribution for large files
- [ ] Package signing with GPG keys
