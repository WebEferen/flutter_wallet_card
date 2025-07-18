# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automating various aspects of the Flutter Wallet Card project.

## Workflows Overview

### 1. CI Workflow (`ci.yml`)

**Triggers:**
- Push to `master` or `develop` branches
- Pull requests to `master` or `develop` branches
- Manual dispatch

**Jobs:**
- **test**: Runs tests on Ubuntu with coverage reporting
- **test-ios**: Tests on macOS for iOS compatibility
- **test-android**: Tests on Ubuntu for Android compatibility
- **package-analysis**: Analyzes package quality and dependencies
- **security-scan**: Scans for security vulnerabilities
- **documentation**: Validates API documentation
- **example-app**: Builds and tests the example application
- **compatibility-check**: Tests against multiple Flutter versions

**Features:**
- Code formatting validation
- Static analysis with `dart analyze`
- Test coverage reporting to Codecov
- Multi-platform testing (iOS, Android)
- Package quality analysis with `pana`
- Security vulnerability scanning
- Documentation completeness checks
- Example app building and artifact upload
- Flutter version compatibility testing

### 2. Documentation Workflow (`docs.yml`)

**Triggers:**
- Push to `master` branch (when docs, lib, README, or CHANGELOG change)
- Manual dispatch

**Jobs:**
- **deploy-docs**: Generates and deploys documentation to GitHub Pages
- **validate-docs**: Validates documentation completeness and links
- **check-links**: Checks external links in documentation
- **preview-docs**: Creates documentation preview for pull requests

**Features:**
- Automatic API documentation generation with `dart doc`
- Jekyll-based GitHub Pages deployment
- Markdown link validation
- Documentation completeness checks
- Pull request documentation previews

### 3. Release Workflow (`release.yml`)

**Triggers:**
- Manual dispatch with version options

**Jobs:**
- **create-release**: Creates a new release with version bumping
- **validate-release**: Validates the release package
- **notify-release**: Sends notifications about release status
- **cleanup-on-failure**: Cleans up on failure

**Features:**
- Automatic version bumping (patch, minor, major)
- Custom version support
- Automatic CHANGELOG.md updates
- Release notes generation
- Package validation
- Example app building
- Automatic cleanup on failure
- Integration with publish workflow

### 4. Publish Workflow (`publish.yml`)

**Triggers:**
- Push to version tags (e.g., `v1.0.0`)
- Manual dispatch

**Jobs:**
- **test**: Runs comprehensive tests before publishing
- **publish**: Publishes package to pub.dev
- **create-release**: Creates GitHub release
- **update-docs**: Updates documentation after publishing

**Features:**
- Pre-publish testing and validation
- Automatic pub.dev publishing
- GitHub release creation with changelog
- Documentation updates
- Artifact generation

## Setup Instructions

### 1. Required Secrets

Add these secrets to your GitHub repository:

#### For Package Publishing:
```
PUB_DEV_PUBLISH_ACCESS_TOKEN
PUB_DEV_PUBLISH_REFRESH_TOKEN
PUB_DEV_PUBLISH_TOKEN_ENDPOINT
PUB_DEV_PUBLISH_EXPIRATION
```

**How to get pub.dev credentials:**
1. Run `dart pub token add https://pub.dev` locally
2. Follow the authentication flow
3. Extract credentials from `~/.pub-cache/credentials.json`
4. Add each field as a GitHub secret

#### For GitHub Operations:
```
GITHUB_TOKEN  # Usually provided automatically
```

### 2. Repository Settings

#### Enable GitHub Pages:
1. Go to repository Settings → Pages
2. Set source to "GitHub Actions"
3. The documentation will be available at `https://username.github.io/repository-name`

#### Branch Protection (Recommended):
1. Go to repository Settings → Branches
2. Add protection rules for `master` branch:
   - Require status checks to pass
   - Require branches to be up to date
   - Include administrators

### 3. Codecov Integration (Optional)

1. Sign up at [codecov.io](https://codecov.io)
2. Connect your GitHub repository
3. No additional secrets needed for public repositories

## Usage Guide

### Creating a Release

1. **Manual Release:**
   - Go to Actions → "Create Release"
   - Click "Run workflow"
   - Choose version type (patch/minor/major) or enter custom version
   - Optionally mark as prerelease or draft
   - Click "Run workflow"

2. **Automatic Release:**
   - Push a version tag: `git tag v1.0.0 && git push origin v1.0.0`
   - The publish workflow will trigger automatically

### Publishing to pub.dev

1. **Automatic (Recommended):**
   - Create a release using the release workflow
   - Publishing happens automatically for non-draft, non-prerelease versions

2. **Manual:**
   - Go to Actions → "Publish to pub.dev"
   - Click "Run workflow"
   - Enter version to publish
   - Click "Run workflow"

### Updating Documentation

1. **Automatic:**
   - Documentation updates automatically when you push to `master`
   - Changes to `docs/`, `lib/`, `README.md`, or `CHANGELOG.md` trigger updates

2. **Manual:**
   - Go to Actions → "Deploy Documentation"
   - Click "Run workflow"

### Running CI Checks

- **Automatic:** CI runs on every push and pull request
- **Manual:** Go to Actions → "CI" → "Run workflow"

## Workflow Customization

### Modifying Flutter Version

Update the Flutter version in all workflows:

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.16.0'  # Change this version
    channel: 'stable'
    cache: true
```

### Adding New Test Platforms

Add new jobs to `ci.yml`:

```yaml
test-web:
  runs-on: ubuntu-latest
  name: Test on Web
  steps:
    # ... setup steps ...
    - name: Run web tests
      run: flutter test --platform chrome
```

### Customizing Documentation

Modify `docs.yml` to change documentation generation:

```yaml
- name: Generate API documentation
  run: |
    dart doc --output docs/api --exclude-packages build_runner
    # Add custom documentation steps
```

### Adding Security Scans

Add security scanning tools to `ci.yml`:

```yaml
- name: Run additional security scan
  run: |
    # Add your security scanning commands
    dart pub global activate security_scanner
    dart pub global run security_scanner
```

## Troubleshooting

### Common Issues

1. **Publishing Fails:**
   - Check pub.dev credentials in secrets
   - Verify package version is unique
   - Ensure all tests pass

2. **Documentation Not Updating:**
   - Check GitHub Pages settings
   - Verify Jekyll build logs
   - Ensure `_config.yml` is valid

3. **CI Failures:**
   - Check Flutter version compatibility
   - Verify all dependencies are available
   - Review test failures in logs

4. **Release Creation Fails:**
   - Check version format (semantic versioning)
   - Verify CHANGELOG.md format
   - Ensure no uncommitted changes

### Debug Steps

1. **Check Workflow Logs:**
   - Go to Actions tab
   - Click on failed workflow
   - Review step-by-step logs

2. **Test Locally:**
   ```bash
   # Run the same commands locally
   flutter pub get
   dart format --output=none --set-exit-if-changed .
   dart analyze --fatal-infos
   flutter test
   dart pub publish --dry-run
   ```

3. **Validate Configuration:**
   ```bash
   # Check workflow syntax
   yamllint .github/workflows/*.yml
   ```

## Best Practices

1. **Version Management:**
   - Use semantic versioning (MAJOR.MINOR.PATCH)
   - Update CHANGELOG.md for each release
   - Test thoroughly before releasing

2. **Documentation:**
   - Keep documentation up to date
   - Include code examples
   - Validate links regularly

3. **Testing:**
   - Maintain high test coverage
   - Test on multiple platforms
   - Include integration tests

4. **Security:**
   - Regularly update dependencies
   - Scan for vulnerabilities
   - Use minimal required permissions

5. **Workflow Maintenance:**
   - Keep actions up to date
   - Monitor workflow performance
   - Review and optimize regularly

## Contributing

When modifying workflows:

1. Test changes in a fork first
2. Update this documentation
3. Follow existing patterns and conventions
4. Add appropriate error handling
5. Include validation steps

For questions or issues with workflows, please open an issue in the repository.