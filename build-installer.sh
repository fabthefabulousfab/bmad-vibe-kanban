#!/usr/bin/env bash
# ===========================================================================
# Build Self-Extracting Installer
# ===========================================================================
# This script creates a self-extracting installer that includes:
#   - BMAD framework and stories (from bmad-templates/)
#   - Vibe Kanban binary (from target/release/server or npx-cli/dist/)
#   - Installation scripts
#
# Prerequisites:
#   - Vibe Kanban must be built first (run ./build-vibe-kanban.sh)
#
# Output:
#   - dist/launch-bmad-vibe-kanban-{platform}.sh (55+ MB)
#     where {platform} is linux-x64, linux-arm64, macos-x64, or macos-arm64
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

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
echo "      [OK] Detected platform: $PLATFORM"
echo ""

echo "╔════════════════════════════════════════════════════════╗"
echo "║         Building BMAD-Vibe-Kanban Installer            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# ===========================================================================
# Verify Prerequisites
# ===========================================================================
echo "[1/3] Checking prerequisites..."

# Check if Vibe Kanban is built
if [ ! -f "$PROJECT_ROOT/target/release/server" ]; then
  echo "ERROR: Vibe Kanban binary not found!"
  echo "Please run: ./build-vibe-kanban.sh first"
  exit 1
fi

# Check if stories are synced
story_count=$(find "$PROJECT_ROOT/frontend/public/stories" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$story_count" -lt 30 ]; then
  echo "ERROR: Stories not synced! Found only $story_count stories."
  echo "Please run: ./build-vibe-kanban.sh first"
  exit 1
fi

echo "      [OK] Vibe Kanban binary found"
echo "      [OK] $story_count stories found"
echo ""

# ===========================================================================
# Build NPX Package (copies target/release/server to npx-cli/dist/)
# ===========================================================================
echo "[2/3] Building NPX package..."

cd "$PROJECT_ROOT"
if [ -f "./local-build.sh" ]; then
  echo "      Running local-build.sh to package binaries..."
  ./local-build.sh
  echo "      [OK] NPX package built"
elif command -v pnpm &> /dev/null; then
  pnpm run build:npx || echo "      [WARN] NPX build failed, using existing build..."
else
  echo "      [WARN] Cannot build NPX package (no build script found)"
  echo "      Continuing with existing build..."
fi

echo "      [OK] NPX package ready"
echo ""

# ===========================================================================
# Call bmad-templates Build Script
# ===========================================================================
echo "[3/3] Creating self-extracting installer..."

cd "$PROJECT_ROOT/bmad-templates"

# Set environment variables for the build script
export BMAD_TEMPLATES_DIR="$PROJECT_ROOT/bmad-templates"
export VIBE_KANBAN_PROJECT="$PROJECT_ROOT"
export OUTPUT_DIR="$PROJECT_ROOT/dist"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Call the installer build script
./scripts/build-installer.sh --output "$OUTPUT_DIR/launch-bmad-vibe-kanban-${PLATFORM}.sh" --platform "$PLATFORM"

echo ""

# ===========================================================================
# Summary
# ===========================================================================
if [ -f "$OUTPUT_DIR/launch-bmad-vibe-kanban-${PLATFORM}.sh" ]; then
  INSTALLER_SIZE=$(du -h "$OUTPUT_DIR/launch-bmad-vibe-kanban-${PLATFORM}.sh" | cut -f1)

  echo "╔════════════════════════════════════════════════════════╗"
  echo "║              INSTALLER BUILD COMPLETE                  ║"
  echo "╚════════════════════════════════════════════════════════╝"
  echo ""
  echo "Installer created:"
  echo "  • File: dist/launch-bmad-vibe-kanban-${PLATFORM}.sh"
  echo "  • Platform: $PLATFORM"
  echo "  • Size: $INSTALLER_SIZE"
  echo "  • Stories: $story_count markdown files"
  echo ""
  echo "To test the installer:"
  echo "  mkdir /tmp/test-install && cd /tmp/test-install"
  echo "  $OUTPUT_DIR/launch-bmad-vibe-kanban-${PLATFORM}.sh --help"
  echo ""
  echo "To distribute:"
  echo "  Upload dist/launch-bmad-vibe-kanban-${PLATFORM}.sh to GitHub Releases"
  echo ""
else
  echo "ERROR: Installer build failed!"
  exit 1
fi
