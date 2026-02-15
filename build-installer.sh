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
#   - dist/install-bmad-vibe-kanban.sh (55+ MB)
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

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

echo "      ✓ Vibe Kanban binary found"
echo "      ✓ $story_count stories found"
echo ""

# ===========================================================================
# Build NPX Package (copies target/release/server to npx-cli/dist/)
# ===========================================================================
echo "[2/3] Building NPX package..."

cd "$PROJECT_ROOT"
if [ -f "./local-build.sh" ]; then
  echo "      Running local-build.sh to package binaries..."
  ./local-build.sh
  echo "      ✓ NPX package built"
elif command -v pnpm &> /dev/null; then
  pnpm run build:npx || echo "      ⚠ NPX build failed, using existing build..."
else
  echo "      ⚠ Cannot build NPX package (no build script found)"
  echo "      Continuing with existing build..."
fi

echo "      ✓ NPX package ready"
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
./scripts/build-installer.sh --output "$OUTPUT_DIR/install-bmad-vibe-kanban.sh"

echo ""

# ===========================================================================
# Summary
# ===========================================================================
if [ -f "$OUTPUT_DIR/install-bmad-vibe-kanban.sh" ]; then
  INSTALLER_SIZE=$(du -h "$OUTPUT_DIR/install-bmad-vibe-kanban.sh" | cut -f1)

  echo "╔════════════════════════════════════════════════════════╗"
  echo "║              INSTALLER BUILD COMPLETE                  ║"
  echo "╚════════════════════════════════════════════════════════╝"
  echo ""
  echo "Installer created:"
  echo "  • File: dist/install-bmad-vibe-kanban.sh"
  echo "  • Size: $INSTALLER_SIZE"
  echo "  • Stories: $story_count markdown files"
  echo ""
  echo "To test the installer:"
  echo "  mkdir /tmp/test-install && cd /tmp/test-install"
  echo "  $OUTPUT_DIR/install-bmad-vibe-kanban.sh --help"
  echo ""
  echo "To distribute:"
  echo "  Upload dist/install-bmad-vibe-kanban.sh to GitHub Releases"
  echo ""
else
  echo "ERROR: Installer build failed!"
  exit 1
fi
