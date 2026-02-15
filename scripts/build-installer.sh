#!/usr/bin/env bash
# ===========================================================================
# Script: build-installer.sh
# Purpose: Build self-extracting installer for bmad-vibe-kanban
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Forward to bmad-templates build script with adjusted paths
export BMAD_TEMPLATES_DIR="$PROJECT_ROOT/bmad-templates"
export VIBE_KANBAN_PROJECT="$PROJECT_ROOT"
export OUTPUT_DIR="$PROJECT_ROOT/dist"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Call the original build-installer.sh from bmad-templates
cd "$BMAD_TEMPLATES_DIR"

# Adjust output path if specified
ARGS=("$@")
for i in "${!ARGS[@]}"; do
  if [[ "${ARGS[$i]}" == "--output" && $((i+1)) < ${#ARGS[@]} ]]; then
    # Output path specified - use it as is
    CUSTOM_OUTPUT="${ARGS[$((i+1))]}"
  fi
done

# If no custom output, use dist/
if [[ -z "${CUSTOM_OUTPUT:-}" ]]; then
  ARGS+=("--output" "$OUTPUT_DIR/install-bmad-vibe-kanban.sh")
fi

exec ./scripts/build-installer.sh "${ARGS[@]}"
