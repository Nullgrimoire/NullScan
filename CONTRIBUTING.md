# Contributing to NullScan

We welcome contributions to NullScan! Here's how you can help make this project better.

## 🚀 Getting Started

### Prerequisites

- [Rust](https://rustup.rs/) (latest stable version)
- Git
- VS Code (recommended) with Rust extensions

### Setting up the Development Environment

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nullscan/nullscan.git
   cd nullscan
   ```

2. **Build the project**:
   ```bash
   cargo build
   ```

3. **Run tests**:
   ```bash
   cargo test
   ```

4. **Run the application**:
   ```bash
   cargo run -- --target 127.0.0.1 --top100
   ```

## 🔧 Development Workflow

### Code Style

- Follow [Rust naming conventions](https://rust-lang.github.io/api-guidelines/naming.html)
- Use `cargo fmt` to format your code
- Run `cargo clippy` to catch common mistakes
- Ensure all tests pass with `cargo test`

### Making Changes

1. **Create a new branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the coding standards

3. **Add tests** for new functionality

4. **Update documentation** if needed

5. **Run the test suite**:
   ```bash
   cargo test
   cargo clippy
   cargo fmt --check
   ```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
cargo test

# Run tests with output
cargo test -- --nocapture

# Run specific test
cargo test test_name
```

### Writing Tests

- Place unit tests in the same file as the code they test
- Use the `#[cfg(test)]` attribute for test modules
- Place integration tests in the `tests/` directory
- Test both success and error cases

Example test:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_feature() {
        // Test implementation
        assert_eq!(result, expected);
    }
}
```

## 📝 Commit Guidelines

### Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(scanner): add support for UDP scanning
fix(banner): handle connection timeout gracefully
docs(readme): update installation instructions
```

## 🐛 Reporting Issues

When reporting issues, please include:

- **NullScan version**: `nullscan --version`
- **Operating system**: Windows/macOS/Linux version
- **Rust version**: `rustc --version`
- **Command used**: The exact command that caused the issue
- **Expected behavior**: What you expected to happen
- **Actual behavior**: What actually happened
- **Error output**: Any error messages or logs

## 💡 Feature Requests

Before submitting a feature request:

1. **Check existing issues** to avoid duplicates
2. **Describe the use case** clearly
3. **Explain the benefit** to users
4. **Consider the implementation** complexity

## 🏗️ Architecture Guidelines

### Project Structure

```
src/
├── main.rs          # CLI interface and application entry point
├── scanner/         # Core scanning functionality
├── banner/          # Service banner detection
├── export/          # Output formatting and export
└── presets/         # Port configuration presets
```

### Design Principles

- **Performance**: Use async/await for I/O operations
- **Safety**: Leverage Rust's type system for memory safety
- **Modularity**: Keep components separate and testable
- **Error Handling**: Use `Result` types consistently
- **Documentation**: Document public APIs with examples

## 🔄 Pull Request Process

1. **Fork the repository** and create your branch from `main`

2. **Make your changes** following the development guidelines

3. **Update documentation** if you're changing functionality

4. **Add tests** for new features or bug fixes

5. **Ensure CI passes**:
   ```bash
   cargo test
   cargo clippy -- -D warnings
   cargo fmt --check
   ```

6. **Write a clear PR description** including:
   - What changes you made
   - Why you made them
   - How to test the changes
   - Any breaking changes

7. **Request review** from maintainers

### PR Review Criteria

- [ ] Code follows project style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No breaking changes (or properly documented)
- [ ] Performance impact is considered
- [ ] Security implications are addressed

## 📋 Development Tasks

Looking for ways to contribute? Check out these areas:

### 🌟 Good First Issues

- Add more service fingerprints to banner detection
- Improve error messages and user experience
- Add more output format options
- Enhance documentation with examples

### 🚀 Advanced Features

- IPv6 support
- UDP scanning capabilities
- Distributed scanning
- Web dashboard interface
- Plugin system for custom checks

### 🔧 Infrastructure

- GitHub Actions CI/CD improvements
- Cross-compilation support
- Package manager integration
- Docker containerization

## 🤝 Community

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and community chat
- **Code Reviews**: Participate in reviewing pull requests

## 📚 Resources

- [Rust Documentation](https://doc.rust-lang.org/)
- [Tokio Documentation](https://docs.rs/tokio/)
- [Clap Documentation](https://docs.rs/clap/)
- [Network Programming in Rust](https://github.com/rust-lang/rustup)

## 🏆 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- GitHub contributors graph

Thank you for contributing to NullScan! 🙏
