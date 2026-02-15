#!/bin/bash
# ===========================================================================
# Script: build-installer.sh
# Purpose: Build self-extracting installer for bmad-vibe-kanban
# Story: 4.1 - Create Build Script for Installer
# Usage: ./scripts/build-installer.sh [OPTIONS]
# ADR-002: Use base64 encoded tar archive for self-extracting installer
# ===========================================================================

set -euo pipefail

# Source shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source common if available, otherwise define minimal logging
if [[ -f "${SCRIPT_DIR}/lib/common.sh" ]]; then
    source "${SCRIPT_DIR}/lib/common.sh"
else
    log_info() { echo "[INFO] $*"; }
    log_success() { echo "[OK] $*"; }
    log_error() { echo "[ERROR] $*" >&2; }
    log_warning() { echo "[WARN] $*"; }
    log_debug() { [[ "${DEBUG:-0}" == "1" ]] && echo "[DEBUG] $*" || true; }
fi

log_debug "build-installer.sh starting"

# ===========================================================================
# Configuration
# ===========================================================================

# Support new unified structure
BMAD_TEMPLATES_DIR="${BMAD_TEMPLATES_DIR:-${PROJECT_ROOT}}"
OUTPUT_FILE="${OUTPUT_FILE:-${PROJECT_ROOT}/install-bmad-vibe-kanban.sh}"
SOURCE_DIR="${BMAD_TEMPLATES_DIR}"
INSTALLER_NAME="install-bmad-vibe-kanban.sh"

# Directories to include in the installer (relative to SOURCE_DIR)
INCLUDE_DIRS=(
    "scripts"
    "stories"
    "templates"
    "_bmad"
    ".claude"
)

# Files to include
INCLUDE_FILES=(
    "VERSION"
)

# Vibe Kanban binary source
# In unified repo: parent of bmad-templates
# In standalone: external project
if [[ -d "${BMAD_TEMPLATES_DIR}/../npx-cli/dist" ]]; then
    VIBE_KANBAN_PROJECT="$(cd "${BMAD_TEMPLATES_DIR}/.." && pwd)"
else
    VIBE_KANBAN_PROJECT="${VIBE_KANBAN_PROJECT:-/Users/fabulousfab/Dev/agents/vibe-kanban}"
fi
VIBE_KANBAN_BINARY_DIR="${VIBE_KANBAN_PROJECT}/npx-cli/dist"

# ===========================================================================
# Help
# ===========================================================================

show_help() {
    log_debug "Showing help"
    cat << 'EOF'
Usage: build-installer.sh [OPTIONS]

Build self-extracting installer for bmad-vibe-kanban.

Options:
    --help              Show this help message
    --output FILE       Output installer path (default: ./install-bmad-vibe-kanban.sh)
    --source-dir DIR    Source directory (default: project root)

The installer embeds:
    - scripts/          Import scripts and libraries
    - stories/          Pre-generated BMAD story files
    - _bmad/            BMAD methodology reference
    - .claude/          Claude Code configuration
    - CLAUDE.md         Project instructions

Examples:
    ./scripts/build-installer.sh
    ./scripts/build-installer.sh --output /tmp/installer.sh
EOF
}

# ===========================================================================
# Parse Arguments
# ===========================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --source-dir)
            SOURCE_DIR="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# ===========================================================================
# Validation
# ===========================================================================

validate_source() {
    log_debug "validate_source called"

    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_error "Source directory not found: $SOURCE_DIR"
        exit 1
    fi

    local missing=0
    for dir in "${INCLUDE_DIRS[@]}"; do
        if [[ ! -d "${SOURCE_DIR}/${dir}" ]]; then
            log_error "Required directory not found: ${dir}"
            missing=1
        fi
    done

    for file in "${INCLUDE_FILES[@]+"${INCLUDE_FILES[@]}"}"; do
        if [[ ! -f "${SOURCE_DIR}/${file}" ]]; then
            log_warning "Optional file not found: ${file}"
        fi
    done

    if [[ $missing -eq 1 ]]; then
        exit 1
    fi

    log_debug "validate_source completed"
}

# ===========================================================================
# Build Functions
# ===========================================================================

create_archive() {
    log_debug "create_archive called"

    local archive_file
    archive_file=$(mktemp)

    # Note: Don't use log_info here as it would be captured by command substitution
    echo "[INFO] Creating archive..." >&2

    # Build list of items to include
    local items=()
    for dir in "${INCLUDE_DIRS[@]}"; do
        if [[ -d "${SOURCE_DIR}/${dir}" ]]; then
            items+=("$dir")
        fi
    done

    for file in "${INCLUDE_FILES[@]+"${INCLUDE_FILES[@]}"}"; do
        if [[ -f "${SOURCE_DIR}/${file}" ]]; then
            items+=("$file")
        fi
    done

    # Create tar archive
    (cd "$SOURCE_DIR" && tar czf "$archive_file" "${items[@]}")

    echo "$archive_file"
    log_debug "create_archive completed"
}

generate_installer() {
    log_debug "generate_installer called"
    local archive_file="$1"

    log_info "Generating installer..."

    # Base64 encode the archive
    local encoded
    encoded=$(base64 < "$archive_file")

    # Create the installer script with full automation
    cat > "$OUTPUT_FILE" << 'INSTALLER_HEADER'
#!/bin/bash
# ===========================================================================
# BMAD-Vibe-Kanban Complete Installer
# Self-extracting + Setup + Dependency Installation + Auto-start
# ===========================================================================

set -euo pipefail

# ===========================================================================
# Configuration
# ===========================================================================

TARGET_DIR="."
SKIP_DEPS=0
SKIP_VIBE=0
AUTO_START=1
VERBOSE=0
CLEAN_MODE=0
DRY_RUN=0
VIBE_KANBAN_PATH=""
NEW_BASH=""
BASH_4_PLUS=""
VIBE_REPO_URL="${VIBE_REPO_URL:-https://github.com/your-org/vibe-kanban.git}"
VIBE_KANBAN_VERSION="0.1.4-local"
BACKEND_PORT=3001
VIBE_BINARY_DIR="${HOME}/.bmad-vibe-kanban/bin"

# Color output
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# ===========================================================================
# Logging Functions (quiet by default, verbose with --verbose)
# ===========================================================================

log_info() {
    if [[ "$VERBOSE" == "1" ]]; then
        echo -e "${BLUE}[INFO]${NC} $*"
    fi
}

log_success() {
    if [[ "$VERBOSE" == "1" ]]; then
        echo -e "${GREEN}[OK]${NC} $*"
    fi
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_debug() {
    if [[ "$VERBOSE" == "1" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $*"
    fi
}

# ===========================================================================
# Help
# ===========================================================================

# Save original arguments before parsing (needed for re-exec with different bash)
ORIGINAL_ARGS=("$@")

show_help() {
    cat << 'EOF'
Usage: install-bmad-vibe-kanban.sh [OPTIONS]

Complete BMAD-Vibe-Kanban installer with automatic setup.

This installer:
  1. Extracts BMAD framework and scripts
  2. Checks system prerequisites
  3. Installs missing dependencies (jq, etc.)
  4. Detects or installs Vibe Kanban
  5. Configures API connection
  6. Launches Vibe Kanban (if needed)
  7. Runs interactive questionnaire

Options:
    --help              Show this help message
    --target DIR        Target directory (default: current directory)
    --clean             Delete existing stories before importing
    --dry-run           Preview import without creating tasks
    --skip-deps         Skip dependency installation
    --skip-vibe         Skip Vibe Kanban setup
    --no-autostart      Don't auto-start questionnaire
    --vibe-path PATH    Path to existing Vibe Kanban installation
    --vibe-url URL      Vibe Kanban repository URL
    --verbose           Show debug output

Examples:
    ./install-bmad-vibe-kanban.sh
    ./install-bmad-vibe-kanban.sh --clean
    ./install-bmad-vibe-kanban.sh --target ~/my-project
    ./install-bmad-vibe-kanban.sh --vibe-path /opt/vibe-kanban
EOF
}

# ===========================================================================
# Parse Arguments
# ===========================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --skip-deps)
            SKIP_DEPS=1
            shift
            ;;
        --skip-vibe)
            SKIP_VIBE=1
            shift
            ;;
        --no-autostart)
            AUTO_START=0
            shift
            ;;
        --clean)
            CLEAN_MODE=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --vibe-path)
            VIBE_KANBAN_PATH="$2"
            shift 2
            ;;
        --vibe-url)
            VIBE_REPO_URL="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=1
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# ===========================================================================
# Header (only in verbose mode)
# ===========================================================================

if [[ "$VERBOSE" == "1" ]]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║  BMAD-Vibe-Kanban Complete Installer                  ║"
    echo "║  Setup • Dependencies • Vibe Kanban • Auto-start       ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
fi

# ===========================================================================
# Extract embedded vibe-kanban binary (defined early for use in all paths)
# ===========================================================================

extract_vibe_binary() {
    # NOTE: This function outputs the binary path to stdout
    # All logging MUST use >&2 to avoid polluting the return value

    # Determine platform
    local platform=""
    local marker=""
    case "$(uname -s)-$(uname -m)" in
        Darwin-arm64)
            platform="macos-arm64"
            marker="__VIBE_MACOS_ARM64_START__"
            ;;
        Darwin-x86_64)
            platform="macos-x64"
            marker="__VIBE_MACOS_X64_START__"
            ;;
        Linux-x86_64)
            platform="linux-x64"
            marker="__VIBE_LINUX_X64_START__"
            ;;
        *)
            echo "[ERROR] Unsupported platform: $(uname -s)-$(uname -m)" >&2
            exit 1
            ;;
    esac

    # Check if binary already extracted
    local vibe_binary="${VIBE_BINARY_DIR}/vibe-kanban"
    if [[ -x "$vibe_binary" ]]; then
        echo "$vibe_binary"
        return 0
    fi

    # Create binary directory
    mkdir -p "$VIBE_BINARY_DIR"

    # Find marker line in installer
    local marker_line
    marker_line=$(grep -n "^${marker}$" "$0" | cut -d: -f1 | head -1)

    if [[ -z "$marker_line" ]]; then
        echo "[ERROR] Embedded binary for $platform not found in installer" >&2
        echo "[ERROR] This installer may not support your platform" >&2
        exit 1
    fi

    echo "[INFO] Extracting embedded vibe-kanban binary..." >&2

    # Extract binary data (from marker+1 to next marker or EOF)
    local start_line=$((marker_line + 1))
    local zip_file="${VIBE_BINARY_DIR}/vibe-kanban.zip"

    # Find end line (next marker or EOF)
    # Disable pipefail temporarily to avoid SIGPIPE errors
    set +o pipefail
    local end_line
    end_line=$(tail -n "+${start_line}" "$0" | awk '/^__VIBE_/{print NR-1; exit}')
    if [[ -n "$end_line" && "$end_line" -gt 0 ]]; then
        tail -n "+${start_line}" "$0" | head -n "$end_line" | base64 -d > "$zip_file"
    else
        tail -n "+${start_line}" "$0" | base64 -d > "$zip_file"
    fi
    set -o pipefail

    # Unzip binary
    if command -v unzip &> /dev/null; then
        unzip -o -q "$zip_file" -d "$VIBE_BINARY_DIR"
    else
        # Fallback: use python if unzip not available
        python3 -c "import zipfile; zipfile.ZipFile('$zip_file').extractall('$VIBE_BINARY_DIR')"
    fi

    # Make executable
    chmod +x "$vibe_binary"

    # Cleanup zip
    rm -f "$zip_file"

    echo "[OK] Binary extracted to: $vibe_binary" >&2

    # Return only the path
    echo "$vibe_binary"
}

# ===========================================================================
# Version information (embedded in installer)
# ===========================================================================

INSTALLER_VERSION="0.1"
INSTALLER_BMAD_VERSION="1.0"

# ===========================================================================
# Check if already installed and compare versions
# ===========================================================================

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || exit 1
EXTRACT_DIR="$(pwd)"

# Version comparison function (returns: 0=equal, 1=first>second, 2=first<second)
version_compare() {
    if [[ "$1" == "$2" ]]; then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=0; i<${#ver1[@]} || i<${#ver2[@]}; i++)); do
        local v1=${ver1[i]:-0}
        local v2=${ver2[i]:-0}
        if ((v1 > v2)); then
            return 1
        elif ((v1 < v2)); then
            return 2
        fi
    done
    return 0
}

# Detect existing installation and version
ALREADY_INSTALLED=0
NEED_UPGRADE=0
INSTALLED_VERSION=""

if [[ -f "VERSION" && -f "scripts/import-bmad-workflow.sh" && -d "_bmad" ]]; then
    # Read installed version
    source VERSION 2>/dev/null || true
    INSTALLED_VERSION="${BMAD_VIBE_KANBAN_VERSION:-unknown}"

    version_compare "$INSTALLER_VERSION" "$INSTALLED_VERSION"
    VERSION_RESULT=$?

    if [[ $VERSION_RESULT -eq 0 ]]; then
        # Same version - just run import
        ALREADY_INSTALLED=1
        log_info "Version $INSTALLED_VERSION already installed"
    elif [[ $VERSION_RESULT -eq 1 ]]; then
        # Installer is newer - upgrade
        NEED_UPGRADE=1
        log_info "Upgrading from v$INSTALLED_VERSION to v$INSTALLER_VERSION..."
    else
        # Installed is newer - ask confirmation
        echo ""
        log_warning "Installed version ($INSTALLED_VERSION) is newer than installer ($INSTALLER_VERSION)"
        echo ""
        read -r -p "Downgrade to v$INSTALLER_VERSION? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            NEED_UPGRADE=1
            log_info "Downgrading to v$INSTALLER_VERSION..."
        else
            log_info "Keeping current version, running import only..."
            ALREADY_INSTALLED=1
        fi
    fi
elif [[ -d "_bmad" || -f "scripts/import-bmad-workflow.sh" ]]; then
    # Partial installation without VERSION file - treat as upgrade
    NEED_UPGRADE=1
    log_info "Found partial installation without version, upgrading..."
fi

# ===========================================================================
# Step 1: Extract files (skip if same version, clean if upgrade)
# ===========================================================================

if [[ "$ALREADY_INSTALLED" == "0" ]]; then
    log_info "Step 1/8: Extracting installation files..."
    log_debug "Extraction directory: $EXTRACT_DIR"

    # Clean up existing files before extraction (upgrade or fresh install)
    if [[ "$NEED_UPGRADE" == "1" || -d "_bmad" ]]; then
        log_info "Cleaning previous installation..."

        # Remove directories
        rm -rf "_bmad" 2>/dev/null || true
        rm -rf "scripts" 2>/dev/null || true
        rm -rf "stories" 2>/dev/null || true
        rm -rf "templates" 2>/dev/null || true
        rm -rf ".claude/commands/bmad" 2>/dev/null || true
        rm -f .claude/commands/bmad*.md 2>/dev/null || true
        rm -f "VERSION" 2>/dev/null || true
        rm -f "HOW TO - BMAD-VIBE-KANBAN.md" 2>/dev/null || true
    fi

    # Extract embedded archive (stops at next marker or EOF)
    # Disable pipefail temporarily to avoid SIGPIPE errors with awk
    set +o pipefail
    ARCHIVE_START_LINE=$(awk '/^__ARCHIVE_START__$/{print NR + 1; exit}' "$0")
    # Find end line (next marker or EOF)
    ARCHIVE_END_LINE=$(tail -n +"$ARCHIVE_START_LINE" "$0" | awk '/^__VIBE_/{print NR-1; exit}')
    set -o pipefail

    # Use temp file for reliable extraction
    TEMP_ARCHIVE=$(mktemp)
    set +o pipefail
    if [[ -n "$ARCHIVE_END_LINE" && "$ARCHIVE_END_LINE" -gt 0 ]]; then
        tail -n +"$ARCHIVE_START_LINE" "$0" | head -n "$ARCHIVE_END_LINE" | base64 -d > "$TEMP_ARCHIVE"
    else
        tail -n +"$ARCHIVE_START_LINE" "$0" | base64 -d > "$TEMP_ARCHIVE"
    fi
    set -o pipefail
    tar xzf "$TEMP_ARCHIVE"
    rm -f "$TEMP_ARCHIVE"

    log_success "Files extracted (v$INSTALLER_VERSION)"
    log_debug "Extracted: scripts, stories, _bmad, .claude, VERSION"

    # Make scripts executable
    chmod +x scripts/*.sh 2>/dev/null || true
    chmod +x scripts/lib/*.sh 2>/dev/null || true
fi

# ===========================================================================
# If already installed, skip to import directly
# ===========================================================================

if [[ "$ALREADY_INSTALLED" == "1" ]]; then
    # Just ensure Vibe Kanban is running
    if [[ "$SKIP_VIBE" == "0" ]]; then
        if ! curl -s "http://127.0.0.1:${BACKEND_PORT}/api/health" &> /dev/null; then
            log_info "Starting Vibe Kanban..."
            VIBE_BINARY=$(extract_vibe_binary)
            PORT=${BACKEND_PORT} nohup "$VIBE_BINARY" > /tmp/vibe-kanban-$$.log 2>&1 &
            sleep 5
        fi
    fi

    # Story import is now done via UI - no automatic shell script execution
    echo ""
    echo "Installation complete!"
    echo ""
    echo "Import workflows via the Vibe Kanban UI:"
    echo "  1. Open Vibe Kanban: http://127.0.0.1:${BACKEND_PORT}"
    echo "  2. Create or select a project"
    echo "  3. Click the orange '+' button in the 'To Do' column"
    echo "  4. Select a workflow and click 'Execute'"
    echo ""

    # Auto-open browser
    if command -v open &> /dev/null; then
        echo "Opening Vibe Kanban in your browser..."
        sleep 2  # Give the server a moment to fully start
        open "http://127.0.0.1:${BACKEND_PORT}"
    fi

    exit 0
fi

# ===========================================================================
# Step 2: Check system prerequisites
# ===========================================================================

log_info "Step 2/8: Checking system prerequisites..."

MISSING_DEPS=()

# Check Bash version and auto-upgrade if needed
BASH_VERSION_MAJOR="${BASH_VERSINFO[0]}"
if [[ $BASH_VERSION_MAJOR -lt 4 ]]; then
    log_warning "Current Bash version is too old: $BASH_VERSION"
    log_info "Looking for newer Bash version on system..."

    # Try to find Bash 4+ in common locations
    BASH_4_PLUS=""
    for bash_path in \
        "/usr/local/bin/bash" \
        "/opt/homebrew/bin/bash" \
        "/opt/local/bin/bash" \
        "/usr/bin/env bash"; do

        if [[ -x "$bash_path" ]]; then
            # Get version of this bash
            FOUND_VERSION=$("$bash_path" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
            FOUND_MAJOR=$(echo "$FOUND_VERSION" | cut -d. -f1)

            if [[ "$FOUND_MAJOR" -ge 4 ]]; then
                BASH_4_PLUS="$bash_path"
                log_success "Found Bash $FOUND_VERSION at: $bash_path"
                break
            fi
        fi
    done

    if [[ -n "$BASH_4_PLUS" ]]; then
        # Re-execute this script with the correct Bash version
        log_info "Re-executing installer with Bash 4+..."
        exec "$BASH_4_PLUS" "$0" ${ORIGINAL_ARGS[@]:+"${ORIGINAL_ARGS[@]}"}
    else
        # No Bash 4+ found, try to install
        log_warning "No Bash 4+ found on system"

        if command -v brew &> /dev/null && [[ "$SKIP_DEPS" == "0" ]]; then
            log_info "Installing Bash via Homebrew..."
            brew install bash &> /dev/null || {
                log_error "Failed to install Bash"
                log_error "Please install Bash 4+ manually: brew install bash"
                exit 1
            }

            # After installation, re-execute with new bash
            NEW_BASH="/usr/local/bin/bash"
            if [[ ! -x "$NEW_BASH" ]]; then
                NEW_BASH="/opt/homebrew/bin/bash"
            fi

            if [[ -x "$NEW_BASH" ]]; then
                log_success "Bash installed successfully"
                log_info "Re-executing installer with new Bash..."
                exec "$NEW_BASH" "$0" ${ORIGINAL_ARGS[@]:+"${ORIGINAL_ARGS[@]}"}
            else
                log_error "Bash installation succeeded but executable not found"
                exit 1
            fi
        else
            log_error "Cannot automatically install Bash"
            log_error "Please run: brew install bash"
            log_error "Then re-run this installer"
            exit 1
        fi
    fi
fi
log_debug "Bash version: $BASH_VERSION (OK)"

# Check required commands
for cmd in curl tar gzip base64 awk grep sed; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_DEPS+=("$cmd")
    fi
done
log_debug "System tools: OK"

# Check jq
if ! command -v jq &> /dev/null; then
    MISSING_DEPS+=("jq")
fi

# Note: npx is no longer required - we use embedded binary
log_debug "Using embedded vibe-kanban binary"

# Check claude (Claude Code CLI)
if ! command -v claude &> /dev/null; then
    log_error "Claude Code CLI is not installed"
    echo ""
    echo "Please install Claude Code:"
    echo "  npm install -g @anthropic-ai/claude-code"
    echo ""
    echo "Or visit: https://docs.anthropic.com/claude-code"
    echo ""
    exit 1
fi
log_debug "claude: OK"

if [[ ${#MISSING_DEPS[@]} -eq 0 ]]; then
    log_success "All prerequisites satisfied"
else
    log_warning "Missing dependencies: ${MISSING_DEPS[*]}"
fi

# ===========================================================================
# Step 3: Install missing dependencies
# ===========================================================================

if [[ ${#MISSING_DEPS[@]} -gt 0 && "$SKIP_DEPS" == "0" ]]; then
    log_info "Step 3/8: Installing missing dependencies..."

    if command -v brew &> /dev/null; then
        # macOS
        for dep in "${MISSING_DEPS[@]}"; do
            log_debug "Installing $dep via brew..."
            brew install "$dep" &> /dev/null || log_warning "Failed to install $dep"
        done
    elif command -v apt-get &> /dev/null; then
        # Ubuntu/Debian
        sudo apt-get update > /dev/null
        for dep in "${MISSING_DEPS[@]}"; do
            log_debug "Installing $dep via apt-get..."
            sudo apt-get install -y "$dep" &> /dev/null || log_warning "Failed to install $dep"
        done
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        for dep in "${MISSING_DEPS[@]}"; do
            log_debug "Installing $dep via yum..."
            sudo yum install -y "$dep" &> /dev/null || log_warning "Failed to install $dep"
        done
    else
        log_warning "Could not automatically install dependencies"
        log_warning "Please install manually: ${MISSING_DEPS[*]}"
    fi

    log_success "Dependency installation complete"
else
    if [[ "$SKIP_DEPS" == "0" ]]; then
        log_success "Step 3/8: No dependencies to install"
    else
        log_info "Step 3/8: Skipping dependency installation (--skip-deps)"
    fi
fi

# ===========================================================================
# Step 4: Git commit extracted files
# ===========================================================================

if git rev-parse --git-dir > /dev/null 2>&1; then
    log_info "Step 4/8: Committing BMAD files to git..."

    # Add the extracted files
    git add scripts/ stories/ templates/ _bmad/ .claude/ 2>/dev/null || true

    # Check if there are changes to commit
    if ! git diff --cached --quiet 2>/dev/null; then
        git commit -m "feat: add BMAD workflow framework

- Add BMAD methodology files (_bmad/)
- Add workflow stories (stories/)
- Add import scripts (scripts/)
- Add project templates (templates/)
- Add Claude Code configuration (.claude/)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>" > /dev/null 2>&1 || true

        log_success "BMAD files committed to git"

        # Push if remote exists
        if git remote get-url origin > /dev/null 2>&1; then
            log_info "Pushing to remote..."
            git push > /dev/null 2>&1 && log_success "Pushed to remote" || log_warning "Failed to push (manual push required)"
        fi
    else
        log_success "No new files to commit"
    fi
else
    log_warning "Not a git repository - skipping git commit"
    log_info "Run 'git init' and commit manually for Vibe Kanban visibility"
fi

# ===========================================================================
# Step 5: Check/Install Vibe Kanban
# ===========================================================================

if [[ "$SKIP_VIBE" == "0" ]]; then
    log_info "Step 5/8: Setting up Vibe Kanban..."

    # Check if already running
    if curl -s "http://127.0.0.1:${BACKEND_PORT}/api/health" &> /dev/null; then
        log_success "Vibe Kanban is already running on port ${BACKEND_PORT}"
    else
        log_info "Vibe Kanban not running, extracting embedded binary..."

        # Extract embedded binary
        VIBE_BINARY=$(extract_vibe_binary)

        # Create log file
        VIBE_LOG="/tmp/vibe-kanban-$$.log"

        # Launch embedded vibe-kanban binary
        log_info "Launching vibe-kanban (embedded binary)..."
        PORT=${BACKEND_PORT} nohup "$VIBE_BINARY" > "$VIBE_LOG" 2>&1 &
        VIBE_PID=$!

        log_debug "Started Vibe Kanban with PID: $VIBE_PID"
        log_debug "Logs: $VIBE_LOG"

        # Wait for Vibe Kanban to be ready
        log_info "Waiting for Vibe Kanban to start..."
        WAITED=0
        MAX_WAIT=30

        while [[ $WAITED -lt $MAX_WAIT ]]; do
            # Check if process is still running
            if ! kill -0 $VIBE_PID 2>/dev/null; then
                log_error "Vibe Kanban process died unexpectedly"
                log_error "Check logs: cat $VIBE_LOG"
                exit 1
            fi

            # Check if API is responding
            if curl -s "http://127.0.0.1:${BACKEND_PORT}/api/health" &> /dev/null; then
                log_success "Vibe Kanban started successfully (PID: $VIBE_PID)"
                log_info "Access Vibe Kanban at: http://127.0.0.1:${BACKEND_PORT}"
                break
            fi

            # Show progress every 10 seconds
            if [[ $((WAITED % 10)) -eq 0 && $WAITED -gt 0 ]]; then
                log_debug "Still waiting... ($WAITED/${MAX_WAIT}s)"
            fi

            sleep 2
            WAITED=$((WAITED + 2))
        done

        if [[ $WAITED -ge $MAX_WAIT ]]; then
            log_error "Vibe Kanban did not start within ${MAX_WAIT} seconds"
            log_error "The process may still be starting (PID: $VIBE_PID)"
            log_error "Check logs: tail -f $VIBE_LOG"
            log_info "You can kill it with: kill $VIBE_PID"
            exit 1
        fi
    fi
else
    log_info "Step 5/8: Skipping Vibe Kanban setup (--skip-vibe)"
fi

# ===========================================================================
# Step 5: Configure API connection
# ===========================================================================

log_info "Step 6/8: Configuring API connection..."

mkdir -p "$EXTRACT_DIR/configs"
cat > "$EXTRACT_DIR/configs/vibe-kanban.conf" << CONFIG_EOF
# Vibe Kanban API Configuration
# Generated by installer at $(date)

VIBE_KANBAN_API="http://127.0.0.1:${BACKEND_PORT}/api"
BACKEND_PORT=${BACKEND_PORT}
DEBUG=false

# Optional: API authentication token
VIBE_KANBAN_TOKEN=""
CONFIG_EOF

log_success "Configuration saved to: $EXTRACT_DIR/configs/vibe-kanban.conf"

# ===========================================================================
# Step 6: Verify installation
# ===========================================================================

log_info "Step 7/8: Verifying installation..."

VERIFIED=1
for dir in scripts stories _bmad .claude configs; do
    if [[ -d "$dir" ]]; then
        log_debug "✓ $dir/"
    else
        log_warning "✗ Missing: $dir/"
        VERIFIED=0
    fi
done

for file in CLAUDE.md; do
    if [[ -f "$file" ]]; then
        log_debug "✓ $file"
    else
        log_warning "✗ Missing: $file"
        VERIFIED=0
    fi
done

if [[ "$VERIFIED" == "1" ]]; then
    log_success "Installation verified"
else
    log_warning "Some files may be missing"
fi

# ===========================================================================
# Step 7: Ready to start
# ===========================================================================

log_info "Step 8/8: Installation complete!"

if [[ "$VERBOSE" == "1" ]]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║  Installation Complete!                               ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "  1. Review CLAUDE.md for project guidelines"
    echo "  2. Import BMAD workflows into your Vibe Kanban project"
    echo ""
fi

# Story import is now done via UI - no automatic shell script execution
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  Import Workflows via Vibe Kanban UI                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "  1. Open Vibe Kanban: http://127.0.0.1:${BACKEND_PORT}"
echo "  2. Create or select a project"
echo "  3. Click the orange '+' button in the 'To Do' column"
echo "  4. Select a workflow and click 'Execute'"
echo ""

# Auto-open browser
if command -v open &> /dev/null; then
    echo "Opening Vibe Kanban in your browser..."
    sleep 2  # Give the server a moment to fully start
    open "http://127.0.0.1:${BACKEND_PORT}"
fi

exit 0

__ARCHIVE_START__
INSTALLER_HEADER

    # Append the base64 encoded archive
    echo "$encoded" >> "$OUTPUT_FILE"

    # Append vibe-kanban binaries marker and data
    log_info "Embedding vibe-kanban binaries..."

    # Embed macOS ARM64 binary
    if [[ -f "${VIBE_KANBAN_BINARY_DIR}/macos-arm64/vibe-kanban.zip" ]]; then
        echo "" >> "$OUTPUT_FILE"
        echo "__VIBE_MACOS_ARM64_START__" >> "$OUTPUT_FILE"
        encode_vibe_binary "macos-arm64" >> "$OUTPUT_FILE"
        log_success "Embedded macos-arm64 binary"
    else
        log_warning "macos-arm64 binary not found, skipping"
    fi

    # Embed macOS x64 binary (if available)
    if [[ -f "${VIBE_KANBAN_BINARY_DIR}/macos-x64/vibe-kanban.zip" ]]; then
        echo "" >> "$OUTPUT_FILE"
        echo "__VIBE_MACOS_X64_START__" >> "$OUTPUT_FILE"
        encode_vibe_binary "macos-x64" >> "$OUTPUT_FILE"
        log_success "Embedded macos-x64 binary"
    fi

    # Embed Linux x64 binary (if available)
    if [[ -f "${VIBE_KANBAN_BINARY_DIR}/linux-x64/vibe-kanban.zip" ]]; then
        echo "" >> "$OUTPUT_FILE"
        echo "__VIBE_LINUX_X64_START__" >> "$OUTPUT_FILE"
        encode_vibe_binary "linux-x64" >> "$OUTPUT_FILE"
        log_success "Embedded linux-x64 binary"
    fi

    # Make executable
    chmod +x "$OUTPUT_FILE"

    log_debug "generate_installer completed"
}

# ===========================================================================
# Check if vibe-kanban binary needs rebuild due to story changes
# ===========================================================================

check_and_rebuild_vibe_if_needed() {
    log_debug "check_and_rebuild_vibe_if_needed called"

    # Check if vibe-kanban project exists
    if [[ ! -d "$VIBE_KANBAN_PROJECT" ]]; then
        log_error "Vibe Kanban project not found: $VIBE_KANBAN_PROJECT"
        log_error "Please clone vibe-kanban or set VIBE_KANBAN_PROJECT environment variable"
        exit 1
    fi

    # Find most recent story file modification time
    local newest_story
    newest_story=$(find "${PROJECT_ROOT}/stories" -type f -name "*.md" -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1 | cut -d' ' -f1)

    if [[ -z "$newest_story" ]]; then
        log_warning "No story files found in ${PROJECT_ROOT}/stories"
        newest_story=0
    fi

    # Find vibe-kanban binary modification time
    local binary_path="${VIBE_KANBAN_BINARY_DIR}/macos-arm64/vibe-kanban.zip"
    local binary_mtime=0

    if [[ -f "$binary_path" ]]; then
        binary_mtime=$(stat -f "%m" "$binary_path" 2>/dev/null || echo 0)
    fi

    log_debug "Newest story timestamp: $newest_story"
    log_debug "Binary timestamp: $binary_mtime"

    # Compare timestamps
    if [[ $newest_story -gt $binary_mtime ]]; then
        log_warning "Stories have been modified after vibe-kanban binary was built"
        log_info "Story changes detected - rebuilding vibe-kanban with latest stories..."

        # Step 1: Sync stories to vibe-kanban
        log_info "Step 1/2: Synchronizing stories to vibe-kanban..."
        if [[ -x "${VIBE_KANBAN_PROJECT}/scripts/sync-stories-from-bmad.sh" ]]; then
            (cd "$VIBE_KANBAN_PROJECT" && ./scripts/sync-stories-from-bmad.sh)
            log_success "Stories synchronized"
        else
            log_info "Syncing stories manually..."
            rsync -a --delete "${PROJECT_ROOT}/stories/" "${VIBE_KANBAN_PROJECT}/frontend/public/stories/"
            log_success "Stories copied to vibe-kanban/frontend/public/stories/"
            log_warning "Manifest update skipped (sync script not found)"
            log_warning "You may need to run: cd ${VIBE_KANBAN_PROJECT} && ./scripts/sync-stories-from-bmad.sh"
        fi

        # Step 2: Rebuild vibe-kanban
        log_info "Step 2/2: Rebuilding vibe-kanban binary..."
        log_info "This may take several minutes (Rust compilation + frontend build)..."

        (
            cd "$VIBE_KANBAN_PROJECT" || exit 1

            # Check for build script
            if [[ -x "./npx-cli/local-build.sh" ]]; then
                ./npx-cli/local-build.sh
            elif command -v pnpm &> /dev/null; then
                pnpm run build:npx
            else
                log_error "Cannot rebuild vibe-kanban: no build script found"
                log_error "Please build manually: cd ${VIBE_KANBAN_PROJECT} && pnpm run build:npx"
                exit 1
            fi
        )

        if [[ $? -eq 0 ]]; then
            log_success "Vibe Kanban rebuilt successfully with latest stories"
        else
            log_error "Vibe Kanban build failed"
            log_error "Please fix the build errors and try again"
            exit 1
        fi
    else
        log_success "Vibe Kanban binary is up-to-date (no story changes detected)"
    fi

    log_debug "check_and_rebuild_vibe_if_needed completed"
}

# ===========================================================================
# Encode vibe-kanban binary
# ===========================================================================

encode_vibe_binary() {
    # Note: This function outputs to stdout which gets captured
    # All logging MUST go to stderr to avoid polluting the base64 data
    echo "[INFO] Encoding vibe-kanban binary for $1..." >&2

    local platform="$1"
    local binary_zip="${VIBE_KANBAN_BINARY_DIR}/${platform}/vibe-kanban.zip"

    if [[ ! -f "$binary_zip" ]]; then
        echo "[ERROR] Vibe Kanban binary not found: $binary_zip" >&2
        echo "[ERROR] Please build vibe-kanban first with: cd ${VIBE_KANBAN_PROJECT} && ./npx-cli/local-build.sh" >&2
        exit 1
    fi

    # Output only base64 data to stdout
    base64 < "$binary_zip"
}

# ===========================================================================
# Main
# ===========================================================================

main() {
    log_debug "main() called"

    echo "=========================================="
    echo "  BMAD-Vibe-Kanban Build"
    echo "=========================================="
    echo ""

    # Step 1: Validate source
    log_info "Validating source directory..."
    validate_source
    log_success "Source validated"

    # Step 2: Check and rebuild vibe-kanban if stories changed
    log_info "Checking vibe-kanban binary freshness..."
    check_and_rebuild_vibe_if_needed

    # Step 3: Create archive
    local archive_file
    archive_file=$(create_archive)
    log_success "Archive created"

    # Step 4: Generate installer
    generate_installer "$archive_file"
    log_success "Installer generated"

    # Step 5: Cleanup
    rm -f "$archive_file"

    # Step 6: Report
    echo ""
    echo "=========================================="
    local size
    size=$(du -h "$OUTPUT_FILE" | cut -f1)
    log_success "Build complete: $OUTPUT_FILE ($size)"
    echo "=========================================="

    log_debug "main() completed"
}

# Run main
main

log_debug "build-installer.sh completed"
