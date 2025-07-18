#!/bin/bash

# Flutter Wallet Card Package Publishing Script
# This script helps with package validation and publishing to pub.dev

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Flutter Wallet Card Publisher${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_dependencies() {
    print_info "Checking dependencies..."
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check if Dart is installed
    if ! command -v dart &> /dev/null; then
        print_error "Dart is not installed or not in PATH"
        exit 1
    fi
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed or not in PATH"
        exit 1
    fi
    
    print_success "Dependencies checked"
}

get_current_version() {
    cd "$PROJECT_ROOT"
    CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | tr -d ' ')
    echo "$CURRENT_VERSION"
}

validate_version_format() {
    local version="$1"
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(\+[0-9]+)?(-[a-zA-Z0-9]+)?$ ]]; then
        print_error "Invalid version format: $version"
        print_info "Expected format: MAJOR.MINOR.PATCH[+BUILD][-PRERELEASE]"
        print_info "Examples: 1.0.0, 1.0.0+1, 1.0.0-beta, 1.0.0+1-beta"
        exit 1
    fi
}

check_git_status() {
    print_info "Checking git status..."
    
    cd "$PROJECT_ROOT"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        print_warning "You have uncommitted changes:"
        git status --porcelain
        echo
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Aborting. Please commit your changes first."
            exit 1
        fi
    fi
    
    print_success "Git status checked"
}

run_tests() {
    print_info "Running tests..."
    
    cd "$PROJECT_ROOT"
    
    # Install dependencies
    print_info "Installing dependencies..."
    flutter pub get
    
    # Check formatting
    print_info "Checking code formatting..."
    if ! dart format --output=none --set-exit-if-changed .; then
        print_error "Code formatting issues found. Run 'dart format .' to fix."
        exit 1
    fi
    
    # Run static analysis
    print_info "Running static analysis..."
    if ! dart analyze --fatal-infos; then
        print_error "Static analysis failed. Please fix the issues."
        exit 1
    fi
    
    # Run tests
    print_info "Running unit tests..."
    if ! flutter test; then
        print_error "Tests failed. Please fix the failing tests."
        exit 1
    fi
    
    print_success "All tests passed"
}

validate_package() {
    print_info "Validating package..."
    
    cd "$PROJECT_ROOT"
    
    # Check package structure
    required_files=(
        "pubspec.yaml"
        "README.md"
        "CHANGELOG.md"
        "LICENSE"
        "lib/flutter_wallet_card.dart"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "Required file missing: $file"
            exit 1
        fi
    done
    
    # Validate pubspec.yaml
    if ! grep -q "^name: flutter_wallet_card" pubspec.yaml; then
        print_error "Package name in pubspec.yaml is incorrect"
        exit 1
    fi
    
    if ! grep -q "^description: " pubspec.yaml; then
        print_error "Package description is missing in pubspec.yaml"
        exit 1
    fi
    
    if ! grep -q "^homepage: " pubspec.yaml; then
        print_warning "Homepage is missing in pubspec.yaml"
    fi
    
    # Check README length
    if [ $(wc -l < README.md) -lt 20 ]; then
        print_warning "README.md seems too short (less than 20 lines)"
    fi
    
    # Check CHANGELOG
    if [ $(wc -l < CHANGELOG.md) -lt 5 ]; then
        print_warning "CHANGELOG.md seems too short (less than 5 lines)"
    fi
    
    print_success "Package structure validated"
}

dry_run_publish() {
    print_info "Running dry-run publish..."
    
    cd "$PROJECT_ROOT"
    
    if ! dart pub publish --dry-run; then
        print_error "Dry-run publish failed. Please fix the issues."
        exit 1
    fi
    
    print_success "Dry-run publish successful"
}

check_pub_credentials() {
    print_info "Checking pub.dev credentials..."
    
    if [ ! -f "$HOME/.pub-cache/credentials.json" ]; then
        print_warning "No pub.dev credentials found"
        print_info "Run 'dart pub token add https://pub.dev' to authenticate"
        read -p "Do you want to continue with authentication? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            dart pub token add https://pub.dev
        else
            print_info "Aborting. Please authenticate first."
            exit 1
        fi
    fi
    
    print_success "Pub.dev credentials found"
}

update_version() {
    local new_version="$1"
    
    print_info "Updating version to $new_version..."
    
    cd "$PROJECT_ROOT"
    
    # Update pubspec.yaml
    sed -i.bak "s/^version: .*/version: $new_version/" pubspec.yaml
    rm pubspec.yaml.bak
    
    # Update CHANGELOG.md
    local date=$(date +"%Y-%m-%d")
    local temp_file=$(mktemp)
    
    echo "# Changelog" > "$temp_file"
    echo "" >> "$temp_file"
    echo "All notable changes to this project will be documented in this file." >> "$temp_file"
    echo "" >> "$temp_file"
    echo "## [$new_version] - $date" >> "$temp_file"
    echo "" >> "$temp_file"
    echo "### Added" >> "$temp_file"
    echo "- Release version $new_version" >> "$temp_file"
    echo "" >> "$temp_file"
    
    # Append existing changelog (skip header)
    if [ -f "CHANGELOG.md" ]; then
        tail -n +4 CHANGELOG.md >> "$temp_file"
    fi
    
    mv "$temp_file" CHANGELOG.md
    
    print_success "Version updated to $new_version"
}

create_git_tag() {
    local version="$1"
    local tag="v$version"
    
    print_info "Creating git tag $tag..."
    
    cd "$PROJECT_ROOT"
    
    # Commit version changes
    git add pubspec.yaml CHANGELOG.md
    git commit -m "chore: bump version to $version"
    
    # Create and push tag
    git tag "$tag"
    
    print_info "Git tag $tag created locally"
    print_warning "Don't forget to push: git push origin main && git push origin $tag"
}

publish_package() {
    print_info "Publishing package to pub.dev..."
    
    cd "$PROJECT_ROOT"
    
    print_warning "This will publish the package to pub.dev!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Aborting publish."
        exit 1
    fi
    
    if ! dart pub publish --force; then
        print_error "Package publish failed"
        exit 1
    fi
    
    print_success "Package published successfully!"
    
    local current_version=$(get_current_version)
    print_info "Package URL: https://pub.dev/packages/flutter_wallet_card/versions/$current_version"
}

show_package_info() {
    cd "$PROJECT_ROOT"
    
    local current_version=$(get_current_version)
    local package_name=$(grep '^name:' pubspec.yaml | sed 's/name: //' | tr -d ' ')
    
    echo -e "${BLUE}Package Information:${NC}"
    echo "  Name: $package_name"
    echo "  Version: $current_version"
    echo "  Location: $PROJECT_ROOT"
    echo
    
    # Show git status
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current)
        local commit=$(git rev-parse --short HEAD)
        echo "  Git Branch: $branch"
        echo "  Git Commit: $commit"
        echo
    fi
    
    # Show pub.dev status
    if [ -f "$HOME/.pub-cache/credentials.json" ]; then
        echo -e "  ${GREEN}Pub.dev: Authenticated${NC}"
    else
        echo -e "  ${RED}Pub.dev: Not authenticated${NC}"
    fi
    echo
}

show_help() {
    echo "Flutter Wallet Card Package Publishing Script"
    echo
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  info      - Show package information"
    echo "  validate  - Validate package without publishing"
    echo "  test      - Run all tests and checks"
    echo "  dry-run   - Run publish dry-run"
    echo "  version   - Update version and create git tag"
    echo "  publish   - Publish package to pub.dev"
    echo "  release   - Full release (validate + version + publish)"
    echo "  help      - Show this help message"
    echo
    echo "Options for 'version' and 'release' commands:"
    echo "  --version VERSION   Specify version (e.g., 1.0.0)"
    echo
    echo "Examples:"
    echo "  $0 info                           # Show package info"
    echo "  $0 validate                       # Validate package"
    echo "  $0 dry-run                        # Test publish"
    echo "  $0 version --version 1.0.0        # Update to version 1.0.0"
    echo "  $0 release --version 1.0.0        # Full release to 1.0.0"
    echo "  $0 publish                        # Publish current version"
    echo
}

# Parse command line arguments
parse_args() {
    COMMAND="${1:-help}"
    shift || true
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --version)
                NEW_VERSION="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main script logic
main() {
    print_header
    
    parse_args "$@"
    
    case "$COMMAND" in
        "info")
            show_package_info
            ;;
        "validate")
            check_dependencies
            check_git_status
            validate_package
            print_success "Package validation complete!"
            ;;
        "test")
            check_dependencies
            run_tests
            print_success "All tests completed successfully!"
            ;;
        "dry-run")
            check_dependencies
            check_git_status
            run_tests
            validate_package
            dry_run_publish
            print_success "Dry-run completed successfully!"
            ;;
        "version")
            if [ -z "$NEW_VERSION" ]; then
                print_error "Version is required. Use --version VERSION"
                exit 1
            fi
            validate_version_format "$NEW_VERSION"
            check_dependencies
            check_git_status
            run_tests
            validate_package
            update_version "$NEW_VERSION"
            create_git_tag "$NEW_VERSION"
            print_success "Version updated to $NEW_VERSION!"
            ;;
        "publish")
            check_dependencies
            check_git_status
            run_tests
            validate_package
            dry_run_publish
            check_pub_credentials
            publish_package
            print_success "Package published successfully!"
            ;;
        "release")
            if [ -z "$NEW_VERSION" ]; then
                print_error "Version is required. Use --version VERSION"
                exit 1
            fi
            validate_version_format "$NEW_VERSION"
            check_dependencies
            check_git_status
            run_tests
            validate_package
            dry_run_publish
            check_pub_credentials
            update_version "$NEW_VERSION"
            create_git_tag "$NEW_VERSION"
            publish_package
            print_success "Release $NEW_VERSION completed successfully!"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"