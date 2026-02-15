#!/usr/bin/env bash
# ===========================================================================
# Script: sync-stories.sh
# Purpose: Sync stories from bmad-templates to vibe-kanban frontend
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "[INFO] Syncing stories from bmad-templates to vibe-kanban..."

# Sync stories
rsync -av --delete \
  "$PROJECT_ROOT/bmad-templates/stories/" \
  "$PROJECT_ROOT/frontend/public/stories/"

echo "[INFO] Updating story manifests..."

# Update manifests in storyParser.ts
PARSER_FILE="$PROJECT_ROOT/frontend/src/services/storyParser.ts"

# Generate manifests for each workflow
generate_manifest() {
  local workflow_dir="$1"
  local workflow_key="$2"

  # List all .md files (excluding templates starting with X-)
  files=$(cd "$PROJECT_ROOT/frontend/public/stories/$workflow_dir" && ls *.md 2>/dev/null | grep -v '^X-' | sort || true)

  if [ -z "$files" ]; then
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

# Replace manifest in storyParser.ts using perl
perl -i -pe "BEGIN{undef $/;} s/  const workflowManifests: Record<string, string\[\]> = \{.*?  \};/$(cat $temp_manifest | sed 's/\//\\\//g' | tr '\n' '§' | sed 's/§/\\n/g')/s" "$PARSER_FILE"

rm "$temp_manifest"

echo "[OK] Stories synchronized and manifests updated"

# Show summary
echo ""
echo "Story counts by workflow:"
cd "$PROJECT_ROOT/frontend/public/stories"
for dir in */; do
  dir_name="${dir%/}"
  count=$(ls "$dir_name"/*.md 2>/dev/null | grep -v '/X-' | wc -l | tr -d ' ')
  echo "  - $dir_name: $count stories"
done
