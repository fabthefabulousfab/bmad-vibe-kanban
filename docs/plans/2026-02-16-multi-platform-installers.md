# Multi-Platform Installer Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create platform-specific installers (macos, ubuntu) instead of one generic installer

**Architecture:** Modify build scripts to detect current platform, build only current platform binary, and create platform-specific installer with single embedded binary

**Tech Stack:** Bash, Rust, Node.js, pnpm

---

## Task 1: Add Platform Detection to Root build-installer.sh

**Files:**
- Modify: `build-installer.sh:1-117`

**Step 1: Add platform detection at start of script**

Add after line 20 (after PROJECT_ROOT definition):

```bash
# ===========================================================================
# Platform Detection
# ===========================================================================
echo "[Platform] Detecting current platform..."

# Detect OS and architecture (same logic as local-build.sh)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names
case "$ARCH" in
  x86_64)
    ARCH="x64"
    ;;
  arm64|aarch64)
    ARCH="arm64"
    ;;
  *)
    echo "ERROR: Unknown architecture $ARCH"
    exit 1
    ;;
esac

# Map OS names
case "$OS" in
  linux)
    OS="linux"
    ;;
  darwin)
    OS="macos"
    ;;
  *)
    echo "ERROR: Unknown OS $OS"
    exit 1
    ;;
esac

PLATFORM="${OS}-${ARCH}"
echo "      ✓ Detected platform: $PLATFORM"
echo ""
```

**Step 2: Update output filename to include platform**

Modify line 87 (the build-installer.sh call):

```bash
# Before:
./scripts/build-installer.sh --output "$OUTPUT_DIR/launch-bmad-vibe-kanban.sh"

# After:
./scripts/build-installer.sh --output "$OUTPUT_DIR/launch-bmad-vibe-kanban-${PLATFORM}.sh" --platform "$PLATFORM"
```

**Step 3: Update summary section to show platform**

Modify lines 94-116:

```bash
# Before:
if [ -f "$OUTPUT_DIR/launch-bmad-vibe-kanban.sh" ]; then
  INSTALLER_SIZE=$(du -h "$OUTPUT_DIR/launch-bmad-vibe-kanban.sh" | cut -f1)

# After:
if [ -f "$OUTPUT_DIR/launch-bmad-vibe-kanban-${PLATFORM}.sh" ]; then
  INSTALLER_SIZE=$(du -h "$OUTPUT_DIR/launch-bmad-vibe-kanban-${PLATFORM}.sh" | cut -f1)
```

Also update the display output:

```bash
echo "Installer created:"
echo "  • File: dist/launch-bmad-vibe-kanban-${PLATFORM}.sh"
echo "  • Platform: $PLATFORM"
echo "  • Size: $INSTALLER_SIZE"
```

**Step 4: Test platform detection**

Run: `./build-installer.sh` (will fail at build step, that's OK for now)
Expected output:
```
[Platform] Detecting current platform...
      ✓ Detected platform: linux-x64
```

**Step 5: Commit**

```bash
git add build-installer.sh
git commit -m "feat: add platform detection to build-installer.sh

- Detect OS and architecture (linux-x64, macos-arm64, etc.)
- Pass platform to bmad-templates build script
- Update output filename to include platform suffix

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Add Cargo PATH to build-vibe-kanban.sh

**Files:**
- Modify: `build-vibe-kanban.sh:1-126`

**Step 1: Add cargo PATH setup after shebang**

Add after line 11 (after set -euo pipefail):

```bash
set -euo pipefail

# ===========================================================================
# Environment Setup
# ===========================================================================
# Ensure Rust/Cargo is in PATH (required for Ubuntu builds)
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
```

**Step 2: Test the change doesn't break macOS**

Run: `./build-vibe-kanban.sh --help` or just check syntax
Expected: No errors (script should still work)

**Step 3: Verify cargo is accessible**

Add debug output after PATH setup:

```bash
# Verify build tools are available
command -v cargo &> /dev/null && echo "      ✓ cargo found: $(cargo --version | head -1)" || echo "      ⚠ cargo not found"
```

**Step 4: Test on Ubuntu (dry run check)**

Run: `bash -n build-vibe-kanban.sh`
Expected: No syntax errors

**Step 5: Commit**

```bash
git add build-vibe-kanban.sh
git commit -m "feat: add cargo PATH support for Ubuntu builds

- Add ~/.cargo/bin to PATH if it exists
- Required for Rust builds on Ubuntu/WSL2
- No impact on macOS builds

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Add Platform Flag to bmad-templates build-installer.sh

**Files:**
- Modify: `bmad-templates/scripts/build-installer.sh:60-117`

**Step 1: Add --platform argument parsing**

Add after line 102 (in the while loop, before the `*` case):

```bash
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
```

**Step 2: Add platform variable initialization**

Add after line 38 (after OUTPUT_FILE):

```bash
OUTPUT_FILE="${OUTPUT_FILE:-${PROJECT_ROOT}/launch-bmad-vibe-kanban.sh}"
PLATFORM="${PLATFORM:-}"  # Will be set by caller or auto-detected
```

**Step 3: Add platform auto-detection if not provided**

Add after line 116 (after argument parsing while loop):

```bash
# ===========================================================================
# Auto-detect platform if not specified
# ===========================================================================

if [[ -z "$PLATFORM" ]]; then
    log_debug "No platform specified, auto-detecting..."

    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    case "$ARCH" in
        x86_64) ARCH="x64" ;;
        arm64|aarch64) ARCH="arm64" ;;
        *) log_error "Unknown architecture: $ARCH"; exit 1 ;;
    esac

    case "$OS" in
        linux) OS="linux" ;;
        darwin) OS="macos" ;;
        *) log_error "Unknown OS: $OS"; exit 1 ;;
    esac

    PLATFORM="${OS}-${ARCH}"
    log_info "Auto-detected platform: $PLATFORM"
fi
```

**Step 4: Update help text**

Modify the show_help function (around line 75):

```bash
Options:
    --help              Show this help message
    --output FILE       Output installer path (default: ./launch-bmad-vibe-kanban.sh)
    --source-dir DIR    Source directory (default: project root)
    --platform PLATFORM Target platform (default: auto-detect, e.g., linux-x64, macos-arm64)
```

**Step 5: Test argument parsing**

Run: `./bmad-templates/scripts/build-installer.sh --help`
Expected: Help shows with new --platform option

**Step 6: Commit**

```bash
git add bmad-templates/scripts/build-installer.sh
git commit -m "feat: add platform flag to installer build script

- Accept --platform argument
- Auto-detect platform if not specified
- Update help text

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Simplify Binary Embedding to Single Platform

**Files:**
- Modify: `bmad-templates/scripts/build-installer.sh:985-1023`

**Step 1: Update generate_installer to use single platform**

Replace lines 990-1017 with:

```bash
    # Append the base64 encoded archive
    echo "$encoded" >> "$OUTPUT_FILE"

    # Append vibe-kanban binary marker and data for current platform only
    log_info "Embedding vibe-kanban binary for $PLATFORM..."

    echo "" >> "$OUTPUT_FILE"
    echo "__VIBE_BINARY_START__" >> "$OUTPUT_FILE"

    if encode_vibe_binary "$PLATFORM" >> "$OUTPUT_FILE"; then
        log_success "Embedded $PLATFORM binary"
    else
        log_error "Failed to embed $PLATFORM binary"
        exit 1
    fi
```

**Step 2: Simplify encode_vibe_binary to use platform parameter**

The function already accepts platform parameter at line 1114, just verify it works correctly.

**Step 3: Update installer runtime to use simplified marker**

In the generate_installer function, modify the embedded installer script.

Replace lines 386-406 (platform detection in installer) with:

```bash
extract_vibe_binary() {
    # NOTE: This function outputs the binary path to stdout
    # All logging MUST use >&2 to avoid polluting the return value

    local vibe_binary="${VIBE_BINARY_DIR}/vibe-kanban"

    # Create binary directory
    mkdir -p "$VIBE_BINARY_DIR"

    # Find binary marker in installer
    local marker_line
    marker_line=$(grep -n "^__VIBE_BINARY_START__$" "$0" | cut -d: -f1 | head -1)

    if [[ -z "$marker_line" ]]; then
        echo "[ERROR] Embedded binary not found in installer" >&2
        echo "[ERROR] This installer may be corrupted" >&2
        exit 1
    fi

    echo "[INFO] Extracting embedded vibe-kanban binary..." >&2

    # Extract binary data (from marker+1 to EOF)
    local start_line=$((marker_line + 1))
    local zip_file="${VIBE_BINARY_DIR}/vibe-kanban.zip"

    # Extract to EOF
    tail -n "+${start_line}" "$0" | base64 -d > "$zip_file"

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
```

**Step 4: Test syntax**

Run: `bash -n bmad-templates/scripts/build-installer.sh`
Expected: No syntax errors

**Step 5: Commit**

```bash
git add bmad-templates/scripts/build-installer.sh
git commit -m "refactor: simplify installer to single-platform binary

- Remove multi-platform binary embedding logic
- Use single __VIBE_BINARY_START__ marker
- Simplify extract_vibe_binary runtime function
- Platform-specific installers no longer need platform detection

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Build and Test Ubuntu Installer

**Files:**
- Test: Build process on Ubuntu

**Step 1: Clean previous builds**

Run:
```bash
rm -rf target/release/server npx-cli/dist/ dist/
```
Expected: Directories removed

**Step 2: Run full build on Ubuntu**

Run:
```bash
./build-installer.sh
```
Expected output:
```
[Platform] Detecting current platform...
      ✓ Detected platform: linux-x64

[1/3] Syncing BMAD stories...
[2/3] Building frontend...
[3/3] Building Rust backend...
[3/3] Creating self-extracting installer...

Installer created:
  • File: dist/launch-bmad-vibe-kanban-linux-x64.sh
  • Platform: linux-x64
  • Size: ~50M+
```

**Step 3: Verify installer file exists**

Run:
```bash
ls -lh dist/launch-bmad-vibe-kanban-linux-x64.sh
```
Expected: File exists, ~50-60MB size

**Step 4: Test installer help**

Run:
```bash
./dist/launch-bmad-vibe-kanban-linux-x64.sh --help
```
Expected: Shows help text without errors

**Step 5: Test installer dry-run**

Run:
```bash
mkdir -p /tmp/test-installer-linux
cd /tmp/test-installer-linux
/home/fab/dev/bmad-vibe-kanban/dist/launch-bmad-vibe-kanban-linux-x64.sh --dry-run --verbose
```
Expected: Extracts files, shows verbose output, doesn't start services

**Step 6: Verify binary extraction**

Run:
```bash
file ~/.bmad-vibe-kanban/bin/vibe-kanban
```
Expected: Shows Linux x86-64 executable

**Step 7: Clean up test**

Run:
```bash
cd /home/fab/dev/bmad-vibe-kanban
rm -rf /tmp/test-installer-linux
```

**Step 8: Commit successful build verification**

```bash
git add -A
git commit -m "test: verify Ubuntu installer build

- Successfully built linux-x64 installer
- Verified file size and execution
- Tested installer help and dry-run modes
- Confirmed binary extraction works

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Update Documentation

**Files:**
- Modify: `README.md` (if exists)
- Create: `docs/build-instructions.md`

**Step 1: Create build instructions document**

```bash
cat > docs/build-instructions.md << 'EOF'
# Build Instructions

## Prerequisites

### Ubuntu/Linux
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# Install Node.js (if not installed)
# Use nvm or your preferred method

# Install pnpm
npm install -g pnpm

# Install zip
sudo apt install zip
```

### macOS
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# Install Node.js (if not installed)
# Use nvm or your preferred method

# Install pnpm
npm install -g pnpm

# zip is pre-installed on macOS
```

## Building the Installer

### On Ubuntu
```bash
./build-installer.sh
# Creates: dist/launch-bmad-vibe-kanban-linux-x64.sh
```

### On macOS (Intel)
```bash
./build-installer.sh
# Creates: dist/launch-bmad-vibe-kanban-macos-x64.sh
```

### On macOS (Apple Silicon)
```bash
./build-installer.sh
# Creates: dist/launch-bmad-vibe-kanban-macos-arm64.sh
```

## Platform Detection

The build system automatically detects your platform:
- Linux x86_64 → `linux-x64`
- macOS Intel → `macos-x64`
- macOS Apple Silicon → `macos-arm64`

Each installer contains only the binary for its target platform.

## Testing the Installer

```bash
# Show help
./dist/launch-bmad-vibe-kanban-<platform>.sh --help

# Dry run (no services started)
./dist/launch-bmad-vibe-kanban-<platform>.sh --dry-run --verbose

# Full installation
./dist/launch-bmad-vibe-kanban-<platform>.sh
```

## Distribution

Upload platform-specific installers to GitHub Releases:
- `launch-bmad-vibe-kanban-linux-x64.sh` (for Ubuntu/Debian)
- `launch-bmad-vibe-kanban-macos-arm64.sh` (for Apple Silicon Macs)
- `launch-bmad-vibe-kanban-macos-x64.sh` (for Intel Macs)
EOF
```

**Step 2: Verify documentation is readable**

Run:
```bash
cat docs/build-instructions.md | head -20
```
Expected: Shows formatted markdown

**Step 3: Commit documentation**

```bash
git add docs/build-instructions.md
git commit -m "docs: add build instructions for multi-platform installers

- Document prerequisites for Ubuntu and macOS
- Explain platform detection
- Add testing and distribution instructions

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Final Verification Checklist

- [ ] Platform detection works on Ubuntu (linux-x64)
- [ ] Build creates `dist/launch-bmad-vibe-kanban-linux-x64.sh`
- [ ] Installer file is executable
- [ ] Installer help works
- [ ] Installer dry-run works
- [ ] Binary extraction succeeds
- [ ] All commits follow conventional commits format
- [ ] Documentation is complete

---

## Notes

**Cross-platform testing:**
- This plan focuses on Ubuntu implementation
- macOS testing should be done on actual macOS hardware
- Consider adding CI/CD for automated multi-platform builds later

**Troubleshooting:**
- If cargo not found: Restart shell or run `source ~/.cargo/env`
- If pnpm not found: Check PATH includes Node.js bin directory
- If build fails: Check all prerequisites installed correctly
