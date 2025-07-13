# 🔄 GitHub Actions Workflows

This directory contains GitHub Actions workflows that automate various aspects of NullScan development, testing, and deployment.

## 📋 Workflow Overview

### 🔍 [`ci.yml`](ci.yml) - CI/CD Pipeline
**Triggers:** Push to main/master/develop, Pull Requests, Tags

**Features:**
- ✅ **Cross-platform testing** (Ubuntu, Windows, macOS)
- ✅ **Multi-Rust version support** (stable, beta)
- ✅ **Code quality checks** (rustfmt, clippy)
- ✅ **Security auditing** with cargo-audit
- ✅ **Code coverage** reporting with Codecov
- ✅ **Automated releases** for tagged versions
- ✅ **Multi-target binary builds** (Linux, Windows, macOS, ARM64)
- ✅ **Performance benchmarks** on PRs

**Build Targets:**
- `x86_64-unknown-linux-gnu` (Linux)
- `x86_64-unknown-linux-musl` (Linux static)
- `x86_64-pc-windows-msvc` (Windows)
- `x86_64-apple-darwin` (macOS Intel)
- `aarch64-apple-darwin` (macOS Apple Silicon)

---

### 🔧 [`maintenance.yml`](maintenance.yml) - Scheduled Maintenance
**Triggers:** Weekly schedule (Mondays 09:00 UTC), Manual dispatch

**Features:**
- 🔄 **Automated dependency updates**
- 🛡️ **Security vulnerability scanning** with Trivy
- 📊 **Dependency audit reports**
- 📤 **Automated pull requests** for updates
- 🔍 **SARIF security reporting**

**Benefits:**
- Keeps dependencies current and secure
- Proactive vulnerability detection
- Automated maintenance workflows

---

### 🎬 [`demo-scripts.yml`](demo-scripts.yml) - Demo Scripts Testing
**Triggers:** Changes to `examples/` directory, Manual dispatch

**Features:**
- 🧪 **Cross-platform script testing**
- 🐍 **Python script validation**
- 🐠 **Fish shell testing**
- 💻 **PowerShell and CMD testing**
- 📋 **Documentation validation**
- 📊 **Coverage matrix generation**

**Tested Combinations:**
- Linux: Bash, Fish, Python
- Windows: PowerShell, CMD, Python
- macOS: Bash, Python

---

### 📚 [`docs.yml`](docs.yml) - Documentation
**Triggers:** Changes to `*.md` files, Manual dispatch

**Features:**
- 🔍 **Markdown linting** with markdownlint
- 🔗 **Link validation** and checking
- 🔤 **Spell checking** with cspell
- 📖 **Auto-generated CLI documentation**
- 🎯 **Feature compatibility matrix**
- 📚 **Rust documentation generation**

**Generated Artifacts:**
- CLI reference documentation
- Feature compatibility matrix
- API documentation

## 🏷️ Workflow Badges

The README includes status badges for all workflows:

- [![CI/CD Pipeline](https://github.com/Nullgrimoire/NullScan/actions/workflows/ci.yml/badge.svg)](https://github.com/Nullgrimoire/NullScan/actions/workflows/ci.yml)
- [![Security Audit](https://github.com/Nullgrimoire/NullScan/actions/workflows/maintenance.yml/badge.svg)](https://github.com/Nullgrimoire/NullScan/actions/workflows/maintenance.yml)
- [![Documentation](https://github.com/Nullgrimoire/NullScan/actions/workflows/docs.yml/badge.svg)](https://github.com/Nullgrimoire/NullScan/actions/workflows/docs.yml)
- [![Demo Scripts](https://github.com/Nullgrimoire/NullScan/actions/workflows/demo-scripts.yml/badge.svg)](https://github.com/Nullgrimoire/NullScan/actions/workflows/demo-scripts.yml)

## 🚀 Release Process

### Automated Releases
1. **Tag creation** triggers the release workflow
2. **Multi-platform binaries** are built automatically
3. **GitHub release** is created with changelog
4. **Artifacts** are attached to the release

### Manual Release Steps
```bash
# Create and push a new tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# The CI/CD pipeline will automatically:
# - Build binaries for all platforms
# - Run security audits
# - Create GitHub release
# - Upload artifacts
```

## 🔒 Security Features

- **Dependency scanning** with Trivy
- **Vulnerability auditing** with cargo-audit
- **SARIF security reporting** to GitHub Security tab
- **Automated security updates**
- **Supply chain security** with Rust toolchain verification

## 🛠️ Development Workflow

### For Contributors
1. **Fork** the repository
2. **Create** a feature branch
3. **Submit** a pull request
4. **Automated checks** run on PR:
   - Code formatting (rustfmt)
   - Linting (clippy)
   - Cross-platform testing
   - Security audits
   - Performance benchmarks

### For Maintainers
- **Weekly maintenance** runs automatically
- **Security alerts** via GitHub Security tab
- **Dependency updates** via automated PRs
- **Release management** via git tags

## 📊 Monitoring & Reporting

- **Build status** visible via badges
- **Test coverage** reported to Codecov
- **Security vulnerabilities** in GitHub Security tab
- **Performance benchmarks** on pull requests
- **Documentation coverage** validation

This comprehensive workflow setup ensures:
- ✅ **Quality assurance** at every step
- ✅ **Security** as a priority
- ✅ **Cross-platform compatibility**
- ✅ **Automated maintenance**
- ✅ **Professional development practices**
