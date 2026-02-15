#!/usr/bin/env bash
# ===========================================================================
# Script: check-story-freshness.sh
# Purpose: Check if stories are newer than binary
# Returns: 0 if up-to-date, 1 if rebuild needed
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Find most recent story file modification time
newest_story=$(find "$PROJECT_ROOT/bmad-templates/stories" -type f -name "*.md" -exec stat -f "%m" {} \; 2>/dev/null | sort -rn | head -1)

if [[ -z "$newest_story" ]]; then
  echo "[WARN] No story files found"
  exit 0
fi

# Find binary modification time
binary_path="$PROJECT_ROOT/npx-cli/dist/macos-arm64/vibe-kanban.zip"
if [[ ! -f "$binary_path" ]]; then
  # Try other platforms
  binary_path=$(find "$PROJECT_ROOT/npx-cli/dist" -name "vibe-kanban.zip" 2>/dev/null | head -1)
fi

if [[ ! -f "$binary_path" ]]; then
  echo "[WARN] Binary not found - rebuild needed"
  exit 1
fi

binary_mtime=$(stat -f "%m" "$binary_path" 2>/dev/null || echo 0)

# Compare
if [[ $newest_story -gt $binary_mtime ]]; then
  echo "[INFO] Stories modified since last build - rebuild needed"
  exit 1
else
  exit 0
fi
