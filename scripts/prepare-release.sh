#!/bin/bash
# NullScan Release Preparation Script

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "❌ Usage: $0 <version>"
    echo "📝 Example: $0 1.0.0"
    exit 1
fi

echo "🚀 Preparing NullScan release v$VERSION"
echo "======================================="

# Validate version format
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Invalid version format. Use semantic versioning (e.g., 1.0.0)"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "❌ There are uncommitted changes. Please commit or stash them first."
    git status --porcelain
    exit 1
fi

# Update version in Cargo.toml
echo "📝 Updating version in Cargo.toml..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version = \".*\"/version = \"$VERSION\"/" Cargo.toml
else
    # Linux
    sed -i "s/^version = \".*\"/version = \"$VERSION\"/" Cargo.toml
fi

# Update Cargo.lock
echo "🔄 Updating Cargo.lock..."
cargo update --workspace

# Run comprehensive tests
echo "🧪 Running comprehensive test suite..."
cargo test --all-features --all-targets

# Check code formatting
echo "📝 Checking code formatting..."
cargo fmt --all -- --check

# Run clippy with strict linting
echo "🔍 Running Clippy analysis..."
cargo clippy --all-targets --all-features -- -D warnings

# Run security audit
echo "🛡️ Running security audit..."
if ! command -v cargo-audit &> /dev/null; then
    echo "📦 Installing cargo-audit..."
    cargo install cargo-audit
fi
cargo audit

# Build release binary to verify everything works
echo "🔨 Building release binary..."
cargo build --release

# Run basic functionality test
echo "🧪 Testing release binary..."
./target/release/nullscan --version
./target/release/nullscan --help > /dev/null

echo "✅ All checks passed!"
echo ""

# Create git commit and tag
echo "🏷️ Creating git commit and tag..."
git add Cargo.toml Cargo.lock
git commit -m "chore: Release v$VERSION

- Update version to $VERSION
- Update Cargo.lock
- All tests passing
- Security audit clean
- Ready for release"

git tag "v$VERSION"

echo "✅ Release v$VERSION prepared successfully!"
echo ""
echo "🚀 To publish the release:"
echo "   1. Push changes: git push origin master"
echo "   2. Push tag: git push origin v$VERSION"
echo "   3. Create GitHub release at: https://github.com/Nullgrimoire/NullScan/releases/new"
echo ""
echo "🤖 The release workflow will automatically:"
echo "   • Build binaries for all platforms"
echo "   • Create release archives with checksums"
echo "   • Upload installation scripts"
echo "   • Generate comprehensive release notes"
echo ""
echo "📋 Release checklist:"
echo "   ✅ Version updated in Cargo.toml"
echo "   ✅ All tests passing"
echo "   ✅ Code formatted correctly"
echo "   ✅ Clippy analysis clean"
echo "   ✅ Security audit passed"
echo "   ✅ Release binary builds successfully"
echo "   ✅ Git tag created"
