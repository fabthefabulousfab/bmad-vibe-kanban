#!/usr/bin/env bash
set -euo pipefail

# Sync stories from bmad-vibe-kanban to vibe-kanban
# This script should be run before building Vibe Kanban to ensure latest stories are included

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source and destination paths
BMAD_STORIES_SRC="$HOME/Dev/agents/bmad-vibe-kanban/stories"
VIBE_STORIES_DEST="$PROJECT_ROOT/frontend/public/stories"
STORY_PARSER="$PROJECT_ROOT/frontend/src/services/storyParser.ts"

echo "=== Syncing BMAD Stories ==="
echo "Source: $BMAD_STORIES_SRC"
echo "Destination: $VIBE_STORIES_DEST"
echo ""

# Check if source exists
if [ ! -d "$BMAD_STORIES_SRC" ]; then
  echo "ERROR: Source directory not found: $BMAD_STORIES_SRC"
  echo "Please ensure bmad-vibe-kanban is cloned at $HOME/Dev/agents/bmad-vibe-kanban"
  exit 1
fi

# Sync stories using rsync
echo "Syncing story files..."
rsync -av --delete "$BMAD_STORIES_SRC/" "$VIBE_STORIES_DEST/"

echo ""
echo "=== Updating Story Manifests ==="

# Generate manifests for each workflow
generate_manifest() {
  local workflow_dir="$1"
  local workflow_key="$2"

  echo "Processing $workflow_key..." >&2

  # List all .md files (excluding templates starting with X-)
  files=$(cd "$VIBE_STORIES_DEST/$workflow_dir" && ls *.md 2>/dev/null | grep -v '^X-' | sort || true)

  if [ -z "$files" ]; then
    echo "  No stories found for $workflow_key" >&2
    return
  fi

  # Format as TypeScript array
  echo "    '$workflow_key': ["
  for file in $files; do
    echo "      '$file',"
  done
  echo "    ],"
}

# Create temporary file with new manifests
temp_manifest=$(mktemp)

cat > "$temp_manifest" << 'EOF'
  const workflowManifests: Record<string, string[]> = {
EOF

generate_manifest "quick-flow" "quick-flow" >> "$temp_manifest"
generate_manifest "debug" "debug" >> "$temp_manifest"
generate_manifest "document-project" "document-project" >> "$temp_manifest"
generate_manifest "workflow-complet" "workflow-complet" >> "$temp_manifest"

cat >> "$temp_manifest" << 'EOF'
  };
EOF

# Replace manifest in storyParser.ts
# Find the start and end of the manifest block
sed_script=$(cat << 'SED'
/^  const workflowManifests: Record<string, string\[\]> = {$/,/^  };$/ {
  /^  const workflowManifests: Record<string, string\[\]> = {$/r TEMP_FILE
  d
}
SED
)

# Use perl for in-place editing (more portable than sed -i)
perl -i -pe "BEGIN{undef $/;} s/  const workflowManifests: Record<string, string\[\]> = \{.*?  \};/$(cat $temp_manifest | sed 's/\//\\\//g' | tr '\n' '§' | sed 's/§/\\n/g')/s" "$STORY_PARSER"

rm "$temp_manifest"

echo ""
echo "=== Summary ==="
echo "✓ Stories synced from bmad-vibe-kanban"
echo "✓ Manifests updated in storyParser.ts"
echo ""
echo "Story counts by workflow:"
cd "$VIBE_STORIES_DEST"
for dir in */; do
  dir_name="${dir%/}"
  count=$(ls "$dir_name"/*.md 2>/dev/null | grep -v '/X-' | wc -l | tr -d ' ')
  echo "  - $dir_name: $count stories"
done

echo ""
echo "Done! You can now build Vibe Kanban with the latest stories."
