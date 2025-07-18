#!/bin/bash

# Flutter Wallet Card Documentation Deployment Script
# This script helps with local development and deployment of documentation

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
DOCS_DIR="$PROJECT_ROOT/docs"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Flutter Wallet Card Docs${NC}"
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
    
    # Check if Ruby is installed (for Jekyll)
    if ! command -v ruby &> /dev/null; then
        print_warning "Ruby is not installed. Jekyll features will not be available."
        RUBY_AVAILABLE=false
    else
        RUBY_AVAILABLE=true
    fi
    
    # Check if Bundle is installed
    if [ "$RUBY_AVAILABLE" = true ] && ! command -v bundle &> /dev/null; then
        print_warning "Bundler is not installed. Run 'gem install bundler' to install."
        BUNDLE_AVAILABLE=false
    else
        BUNDLE_AVAILABLE=true
    fi
    
    print_success "Dependencies checked"
}

setup_project() {
    print_info "Setting up project..."
    
    cd "$PROJECT_ROOT"
    
    # Install Flutter dependencies
    print_info "Installing Flutter dependencies..."
    flutter pub get
    
    print_success "Project setup complete"
}

generate_api_docs() {
    print_info "Generating API documentation..."
    
    cd "$PROJECT_ROOT"
    
    # Create API docs directory if it doesn't exist
    mkdir -p "$DOCS_DIR/api"
    
    # Generate Dart documentation
    dart doc --output "$DOCS_DIR/api" --validate-links
    
    print_success "API documentation generated"
}

setup_jekyll() {
    if [ "$RUBY_AVAILABLE" = false ] || [ "$BUNDLE_AVAILABLE" = false ]; then
        print_warning "Skipping Jekyll setup (Ruby/Bundler not available)"
        return
    fi
    
    print_info "Setting up Jekyll..."
    
    cd "$DOCS_DIR"
    
    # Create Gemfile if it doesn't exist
    if [ ! -f "Gemfile" ]; then
        print_info "Creating Gemfile..."
        cat > Gemfile << EOF
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
gem "jekyll-include-cache", group: :jekyll_plugins
gem "jekyll-sitemap", group: :jekyll_plugins
gem "jekyll-feed", group: :jekyll_plugins
gem "jekyll-seo-tag", group: :jekyll_plugins
EOF
    fi
    
    # Install Jekyll dependencies
    print_info "Installing Jekyll dependencies..."
    bundle install
    
    print_success "Jekyll setup complete"
}

build_docs() {
    print_info "Building documentation..."
    
    # Copy important files to docs directory
    cp "$PROJECT_ROOT/README.md" "$DOCS_DIR/"
    cp "$PROJECT_ROOT/CHANGELOG.md" "$DOCS_DIR/"
    
    if [ "$BUNDLE_AVAILABLE" = true ]; then
        cd "$DOCS_DIR"
        bundle exec jekyll build --destination _site
        print_success "Jekyll site built successfully"
    else
        print_warning "Jekyll not available, skipping site build"
    fi
    
    print_success "Documentation build complete"
}

serve_docs() {
    if [ "$BUNDLE_AVAILABLE" = false ]; then
        print_error "Jekyll is required to serve documentation locally"
        print_info "Install Ruby and Bundler, then run this script again"
        exit 1
    fi
    
    print_info "Starting local documentation server..."
    
    cd "$DOCS_DIR"
    
    print_success "Documentation server starting..."
    print_info "Open http://localhost:4000 in your browser"
    print_info "Press Ctrl+C to stop the server"
    
    bundle exec jekyll serve --livereload --open-url
}

validate_docs() {
    print_info "Validating documentation..."
    
    # Check if all required files exist
    required_files=(
        "$DOCS_DIR/index.md"
        "$DOCS_DIR/getting-started.md"
        "$DOCS_DIR/api-reference.md"
        "$DOCS_DIR/platform-setup.md"
        "$DOCS_DIR/examples.md"
        "$DOCS_DIR/migration.md"
        "$DOCS_DIR/_config.yml"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "Required file missing: $file"
            exit 1
        fi
    done
    
    # Validate markdown files
    if command -v markdown-link-check &> /dev/null; then
        print_info "Checking markdown links..."
        find "$DOCS_DIR" -name "*.md" -exec markdown-link-check {} \;
    else
        print_warning "markdown-link-check not installed, skipping link validation"
    fi
    
    print_success "Documentation validation complete"
}

clean_docs() {
    print_info "Cleaning documentation build files..."
    
    rm -rf "$DOCS_DIR/_site"
    rm -rf "$DOCS_DIR/.jekyll-cache"
    rm -rf "$DOCS_DIR/api"
    
    print_success "Documentation cleaned"
}

show_help() {
    echo "Flutter Wallet Card Documentation Deployment Script"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  setup     - Setup project and install dependencies"
    echo "  generate  - Generate API documentation"
    echo "  build     - Build complete documentation site"
    echo "  serve     - Serve documentation locally (requires Jekyll)"
    echo "  validate  - Validate documentation completeness"
    echo "  clean     - Clean build files"
    echo "  deploy    - Full deployment (setup + generate + build)"
    echo "  dev       - Development mode (deploy + serve)"
    echo "  help      - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 dev      # Start local development server"
    echo "  $0 deploy   # Build documentation for deployment"
    echo "  $0 clean    # Clean all build files"
    echo
}

# Main script logic
main() {
    print_header
    
    case "${1:-help}" in
        "setup")
            check_dependencies
            setup_project
            setup_jekyll
            ;;
        "generate")
            check_dependencies
            generate_api_docs
            ;;
        "build")
            check_dependencies
            generate_api_docs
            setup_jekyll
            build_docs
            ;;
        "serve")
            check_dependencies
            serve_docs
            ;;
        "validate")
            validate_docs
            ;;
        "clean")
            clean_docs
            ;;
        "deploy")
            check_dependencies
            setup_project
            generate_api_docs
            setup_jekyll
            build_docs
            validate_docs
            print_success "Documentation deployment complete!"
            ;;
        "dev")
            check_dependencies
            setup_project
            generate_api_docs
            setup_jekyll
            build_docs
            print_success "Starting development server..."
            serve_docs
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"