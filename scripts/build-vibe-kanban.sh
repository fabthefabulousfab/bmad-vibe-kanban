#!/usr/bin/env bash
# ===========================================================================
# Script: build-vibe-kanban.sh
# Purpose: Build Vibe Kanban with automatic story sync if needed
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "  Building Vibe Kanban"
echo "=========================================="
echo ""

# Check for story modifications
if "$SCRIPT_DIR/check-story-freshness.sh" 2>&1; then
  echo "[OK] Stories are up-to-date"
else
  echo "[INFO] Stories modified - syncing..."
  "$SCRIPT_DIR/sync-stories.sh"
fi

echo ""
echo "[INFO] Building frontend..."
cd "$PROJECT_ROOT/frontend"
pnpm run build

echo ""
echo "[INFO] Building backend..."
cd "$PROJECT_ROOT"
cargo build --release

echo ""
echo "[INFO] Building NPX binary..."
cd "$PROJECT_ROOT/npx-cli"
./local-build.sh

echo ""
echo "=========================================="
echo "[OK] Vibe Kanban build complete"
echo "=========================================="
