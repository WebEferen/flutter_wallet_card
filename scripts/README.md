# Flutter Wallet Card Scripts

This directory contains utility scripts for development and publishing workflows for the Flutter Wallet Card project.

## 📁 Scripts Overview

### 📦 `publish-package.sh`
Package publishing and release management script.

**Purpose:** Handles package validation, versioning, and publishing to pub.dev.

**Features:**
- Comprehensive package validation
- Automated testing and quality checks
- Version management and git tagging
- Pub.dev publishing with safety checks
- Full release workflow automation

## 🛠️ Prerequisites

### Required Tools
- **Flutter SDK** (3.13.0 or later)
- **Dart SDK** (included with Flutter)
- **Git** (for version control)

### Optional Tools
- **OSV Scanner** (for security scanning)
- **pana** (for package analysis)

### Installation Commands
```bash
# Install Dart tools (optional)
dart pub global activate pana
```

## 📦 Publishing Scripts

### `publish-package.sh`

#### Quick Start
```bash
# Check package status
./scripts/publish-package.sh info

# Validate package
./scripts/publish-package.sh validate

# Full release
./scripts/publish-package.sh release --version 1.0.0
```

#### Available Commands

| Command | Description | Use Case |
|---------|-------------|----------|
| `info` | Show package information | Status check |
| `validate` | Validate package structure | Pre-publish check |
| `test` | Run all tests and checks | Quality assurance |
| `dry-run` | Test publish without uploading | Safety check |
| `version` | Update version and create tag | Version management |
| `publish` | Publish to pub.dev | Package release |
| `release` | Full release workflow | Complete release |

#### Examples

**Package Information:**
```bash
./scripts/publish-package.sh info
# Shows: name, version, git status, auth status
```

**Pre-publish Validation:**
```bash
# Comprehensive validation
./scripts/publish-package.sh validate

# Test publish (no upload)
./scripts/publish-package.sh dry-run
```

**Version Management:**
```bash
# Update version and create git tag
./scripts/publish-package.sh version --version 1.2.0

# This will:
# 1. Update pubspec.yaml
# 2. Update CHANGELOG.md
# 3. Commit changes
# 4. Create git tag v1.2.0
```

**Publishing:**
```bash
# Publish current version
./scripts/publish-package.sh publish

# Full release (recommended)
./scripts/publish-package.sh release --version 1.2.0
```

#### Release Workflow
The `release` command performs:
1. ✅ Dependency checks
2. ✅ Git status validation
3. ✅ Code formatting check
4. ✅ Static analysis
5. ✅ Unit tests
6. ✅ Package structure validation
7. ✅ Dry-run publish
8. ✅ Pub.dev authentication check
9. 🔄 Version update
10. 🔄 Git tag creation
11. 🚀 Package publishing

## 🔧 Configuration

### Environment Setup

#### Pub.dev Authentication
```bash
# Authenticate with pub.dev
dart pub token add https://pub.dev

# Verify authentication
ls ~/.pub-cache/credentials.json
```

#### Git Configuration
```bash
# Set git user (if not already set)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Script Customization

#### Publishing Script
Edit `publish-package.sh` to customize:

```bash
# Add custom validation
validate_custom() {
    # Your custom validation logic
    echo "Running custom validation..."
}

# Modify version update logic
update_version() {
    # Your custom version update logic
}
```

## 🚨 Troubleshooting

### Common Issues

#### Publishing Issues

**Authentication fails:**
```bash
# Re-authenticate
dart pub token add https://pub.dev

# Check credentials
cat ~/.pub-cache/credentials.json
```

**Tests fail:**
```bash
# Run tests manually
flutter test

# Check specific test
flutter test test/specific_test.dart

# Run with coverage
flutter test --coverage
```

**Version conflicts:**
```bash
# Check current version
grep '^version:' pubspec.yaml

# Check pub.dev for existing versions
curl -s https://pub.dev/api/packages/flutter_wallet_card | jq '.versions'
```

**Git issues:**
```bash
# Check git status
git status

# Commit pending changes
git add .
git commit -m "Prepare for release"

# Check remote
git remote -v
```

### Debug Mode

Run scripts with debug output:

```bash
# Enable bash debug mode
bash -x ./scripts/publish-package.sh validate

# Or add debug flag to script
set -x  # Add this line to script for debugging
```

### Log Files

Scripts create temporary files during execution:

```bash
# Check temporary files
ls /tmp/flutter_wallet_card_*

# Pub publish logs
cat ~/.pub-cache/log/pub_log.txt
```

## 🔄 CI/CD Integration

### GitHub Actions

These scripts are designed to work with the GitHub Actions workflows:

- **`ci.yml`** - Uses validation logic from `publish-package.sh`
- **`publish.yml`** - Uses publishing logic from `publish-package.sh`
- **`release.yml`** - Uses publishing logic for releases

### Local Testing

Test workflows locally before pushing:

```bash
# Test publishing workflow
./scripts/publish-package.sh dry-run

# Test full release workflow
./scripts/publish-package.sh validate
```

## 📋 Best Practices

### Development Workflow

1. **Before making changes:**
   ```bash
   ./scripts/publish-package.sh info
   ./scripts/publish-package.sh validate
   ```

2. **Before committing:**
   ```bash
   ./scripts/publish-package.sh test
   ```

3. **Before releasing:**
   ```bash
   ./scripts/publish-package.sh dry-run
   ```

### Release Workflow

1. **Prepare release:**
   - Update documentation
   - Write changelog entries
   - Test thoroughly

2. **Create release:**
   ```bash
   ./scripts/publish-package.sh release --version X.Y.Z
   ```

3. **Post-release:**
   - Verify package on pub.dev
   - Update GitHub release notes

### Security Considerations

- **Never commit credentials** to version control
- **Use environment variables** for sensitive data
- **Validate inputs** before processing
- **Use dry-run** before actual publishing
- **Review changes** before releasing

## 🤝 Contributing

When modifying scripts:

1. **Test thoroughly** on different environments
2. **Update documentation** for any changes
3. **Follow existing patterns** and conventions
4. **Add error handling** for edge cases
5. **Include help text** for new options

### Script Development Guidelines

- Use `set -e` for error handling
- Provide colored output for better UX
- Include comprehensive help text
- Validate inputs and dependencies
- Use temporary files safely
- Clean up on exit

## 📞 Support

For issues with scripts:

1. Check this documentation
2. Review script help: `./script-name.sh help`
3. Check GitHub Issues
4. Create new issue with:
   - Script name and command used
   - Full error output
   - Environment details (OS, Flutter version, etc.)

---

**Last Updated:** This documentation is maintained alongside the scripts and updated with each release.