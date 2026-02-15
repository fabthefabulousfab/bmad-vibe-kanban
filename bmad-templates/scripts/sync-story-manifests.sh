#!/bin/bash
# ===========================================================================
# Script: sync-story-manifests.sh
# Purpose: Generate story file manifests for frontend storyParser
# Usage: ./scripts/sync-story-manifests.sh
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STORIES_SOURCE="${SCRIPT_DIR}/../stories"
PARSER_FILE="${SCRIPT_DIR}/../vibe-kanban/frontend/src/services/storyParser.ts"

echo "Generating story manifests..."

# Function to list .md files in a directory (excluding X-X-X templates)
list_stories() {
    local dir="$1"
    find "$dir" -maxdepth 1 -name "*.md" -type f | \
        grep -v "X-X-X-" | \
        xargs -n1 basename | \
        sort -t'-' -k1,1n -k2,2n -k3,3n
}

# Generate JavaScript array for a workflow
generate_manifest() {
    local workflow="$1"
    local stories_dir="${STORIES_SOURCE}/${workflow}"

    if [[ ! -d "$stories_dir" ]]; then
        echo "[]"
        return
    fi

    echo "["
    list_stories "$stories_dir" | while read -r file; do
        echo "      '${file}',"
    done
    echo "    ]"
}

# Generate the manifests object
echo "  const workflowManifests: Record<string, string[]> = {"

for workflow in quick-flow debug document-project workflow-complet; do
    echo "    '${workflow}': $(generate_manifest "$workflow" | tr '\n' ' ' | sed 's/  */ /g'),"
done

echo "  };"
echo ""
echo "Manifests generated. Please update storyParser.ts manually with the output above."
echo ""
echo "Story counts:"
for workflow in quick-flow debug document-project workflow-complet; do
    count=$(list_stories "${STORIES_SOURCE}/${workflow}" 2>/dev/null | wc -l | tr -d ' ')
    echo "  ${workflow}: ${count} stories"
done
