#!/usr/bin/env bash

# ==============================================================================
# Cloudflare Workers Build Script for MkDocs Material Site
# ==============================================================================
#
# This script installs necessary tools and builds the MkDocs site for
# deployment to Cloudflare Workers.
#
# Usage:
#   ./scripts/cloudflare.worker.sh [command]
#
# Commands:
#   full        - Install dependencies and build (default)
#   install     - Install dependencies only
#   build       - Build site only (assumes dependencies installed)
#   clean       - Clean build artifacts
#   help        - Show this help message
#
# Requirements:
#   - Python 3.13+ (or 3.11+)
#   - uv (Python package installer) or pip
#   - Git
#
# ==============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Python version
check_python_version() {
    log_info "Checking Python version..."

    if ! command_exists python3; then
        log_error "Python 3 is not installed"
        log_info "Please install Python 3.11+ from https://www.python.org/downloads/"
        exit 1
    fi

    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
    PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

    log_info "Found Python $PYTHON_VERSION"

    # Check if version is 3.11+
    if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 11 ]; then
        log_warning "Python 3.11+ is recommended, but found $PYTHON_VERSION"
        log_warning "Build may work, but some features may not be available"
    fi
}

# Function to install uv if not present
install_uv() {
    if command_exists uv; then
        log_success "uv is already installed ($(uv --version))"
        return 0
    fi

    log_info "Installing uv (fast Python package installer)..."

    # Try to install uv using the official installer
    if command_exists curl; then
        curl -LsSf https://astral.sh/uv/install.sh | sh

        # Add uv to PATH for current session
        export PATH="$HOME/.cargo/bin:$PATH"

        if command_exists uv; then
            log_success "uv installed successfully"
        else
            log_error "Failed to install uv"
            exit 1
        fi
    else
        log_error "curl is not installed. Cannot install uv."
        log_info "Please install curl or manually install uv from https://docs.astral.sh/uv/"
        exit 1
    fi
}

# Function to install Python dependencies
install_dependencies() {
    log_info "Installing Python dependencies..."

    if command_exists uv; then
        log_info "Using uv for fast dependency installation..."
        uv sync --frozen
        log_success "Dependencies installed with uv"
    elif command_exists pip; then
        log_info "Using pip for dependency installation..."
        pip install -r requirements.txt || {
            log_error "requirements.txt not found. Generating from pyproject.toml..."
            pip install .
        }
        log_success "Dependencies installed with pip"
    else
        log_error "Neither uv nor pip found. Cannot install dependencies."
        exit 1
    fi
}

# Function to install system dependencies (optional, for Cairo/Pillow)
install_system_dependencies() {
    log_info "Checking system dependencies for image optimization..."

    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command_exists apt-get; then
            log_info "Detected Debian/Ubuntu system"
            log_info "Installing Cairo and image libraries..."
            sudo apt-get update -qq
            sudo apt-get install -y -qq libcairo2-dev pkg-config python3-dev \
                                       libjpeg-dev zlib1g-dev || true
        elif command_exists yum; then
            log_info "Detected RHEL/CentOS system"
            log_info "Installing Cairo and image libraries..."
            sudo yum install -y cairo-devel pkg-config python3-devel \
                                libjpeg-devel zlib-devel || true
        else
            log_warning "Unknown Linux distribution. Skipping system dependencies."
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command_exists brew; then
            log_info "Detected macOS system"
            log_info "Installing Cairo and image libraries..."
            brew install cairo pkg-config || true
        else
            log_warning "Homebrew not installed. Skipping system dependencies."
            log_info "Install Homebrew from https://brew.sh/ for optimal performance"
        fi
    else
        log_warning "Unknown OS. Skipping system dependencies."
    fi
}

# Function to build the site
build_site() {
    log_info "Building MkDocs site..."

    # Check if mkdocs.yml exists
    if [ ! -f "mkdocs.yml" ]; then
        log_error "mkdocs.yml not found. Are you in the project root?"
        exit 1
    fi

    # Build with uv or directly with mkdocs
    if command_exists uv; then
        log_info "Building with uv run mkdocs build..."
        uv run mkdocs build --clean --strict
    else
        log_info "Building with mkdocs..."
        mkdocs build --clean --strict
    fi

    # Check if build succeeded
    if [ -d "site" ]; then
        SITE_SIZE=$(du -sh site | awk '{print $1}')
        log_success "Site built successfully! (size: $SITE_SIZE)"
        log_info "Output directory: site/"
    else
        log_error "Build failed. No 'site' directory created."
        exit 1
    fi
}

# Function to clean build artifacts
clean_build() {
    log_info "Cleaning build artifacts..."

    if [ -d "site" ]; then
        rm -rf site
        log_success "Removed site/ directory"
    else
        log_info "No site/ directory to clean"
    fi

    # Clean Python cache
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true

    log_success "Cleanup complete"
}

# Function to show help
show_help() {
    cat << EOF
${BLUE}Cloudflare Workers Build Script for MkDocs Material${NC}

${GREEN}Usage:${NC}
  ./scripts/cloudflare.worker.sh [command]

${GREEN}Commands:${NC}
  full        - Install dependencies and build (default)
  install     - Install dependencies only
  build       - Build site only (assumes dependencies installed)
  clean       - Clean build artifacts
  help        - Show this help message

${GREEN}Examples:${NC}
  ./scripts/cloudflare.worker.sh full      # Full build (install + build)
  ./scripts/cloudflare.worker.sh install   # Only install dependencies
  ./scripts/cloudflare.worker.sh build     # Only build site
  ./scripts/cloudflare.worker.sh clean     # Clean build artifacts

${GREEN}Requirements:${NC}
  - Python 3.11+ (3.13+ recommended)
  - uv (will be auto-installed if missing)
  - Git

${GREEN}Environment Variables:${NC}
  SKIP_SYSTEM_DEPS=1   Skip system dependency installation

${YELLOW}Note:${NC}
  This script is designed to work in Cloudflare Workers build environment
  and local development environments.

For more information, see: https://developers.cloudflare.com/pages/

EOF
}

# Function to display build info
display_build_info() {
    log_info "========================================="
    log_info "  MkDocs Site Build Information"
    log_info "========================================="
    log_info "Python: $(python3 --version 2>&1 | awk '{print $2}')"

    if command_exists uv; then
        log_info "uv: $(uv --version 2>&1)"
    fi

    if command_exists mkdocs; then
        log_info "MkDocs: $(mkdocs --version 2>&1 | grep -oP 'version \K[0-9.]+')"
    fi

    log_info "Working directory: $(pwd)"
    log_info "========================================="
}

# Main execution
main() {
    # Get command (default to 'full')
    COMMAND="${1:-full}"

    case "$COMMAND" in
        full)
            log_info "Starting full build (install + build)..."
            display_build_info
            check_python_version

            # Install uv if not present
            install_uv

            # Install system dependencies (unless skipped)
            if [ -z "${SKIP_SYSTEM_DEPS:-}" ]; then
                install_system_dependencies
            else
                log_warning "Skipping system dependency installation (SKIP_SYSTEM_DEPS=1)"
            fi

            # Install Python dependencies
            install_dependencies

            # Build the site
            build_site

            log_success "Full build complete! 🚀"
            log_info "Deploy to Cloudflare Workers with: wrangler deploy"
            ;;

        install)
            log_info "Installing dependencies only..."
            display_build_info
            check_python_version
            install_uv

            if [ -z "${SKIP_SYSTEM_DEPS:-}" ]; then
                install_system_dependencies
            fi

            install_dependencies
            log_success "Dependencies installed! ✓"
            ;;

        build)
            log_info "Building site only..."
            build_site
            log_success "Build complete! ✓"
            ;;

        clean)
            clean_build
            ;;

        help|--help|-h)
            show_help
            ;;

        *)
            log_error "Unknown command: $COMMAND"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
