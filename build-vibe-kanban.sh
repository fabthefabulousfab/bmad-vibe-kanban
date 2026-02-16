#!/usr/bin/env bash
# ===========================================================================
# Build Vibe Kanban with BMAD Stories
# ===========================================================================
# This script builds the complete Vibe Kanban application with embedded
# BMAD stories from bmad-templates/
#
# Output:
#   - target/release/server (Rust backend with embedded frontend)
#   - npx-cli/dist/ (NPM packages)
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

echo "╔════════════════════════════════════════════════════════╗"
echo "║           Building BMAD-Vibe-Kanban                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# ===========================================================================
# Step 1: Sync Stories from bmad-templates to frontend
# ===========================================================================
echo "[1/3] Syncing BMAD stories from bmad-templates..."
echo "      Source: bmad-templates/stories/"
echo "      Target: frontend/public/stories/"

rsync -a --delete \
  "$PROJECT_ROOT/bmad-templates/stories/" \
  "$PROJECT_ROOT/frontend/public/stories/"

echo "      ✓ $(find frontend/public/stories -name "*.md" | wc -l | tr -d ' ') stories synced"

# Update manifests in storyParser.ts
PARSER_FILE="$PROJECT_ROOT/frontend/src/services/storyParser.ts"

generate_manifest() {
  local workflow_dir="$1"
  local workflow_key="$2"

  files=$(cd "$PROJECT_ROOT/frontend/public/stories/$workflow_dir" && ls *.md 2>/dev/null | grep -v '^X-' | sort || true)

  if [ -z "$files" ]; then
    return
  fi

  echo "    '$workflow_key': ["
  for file in $files; do
    echo "      '$file',"
  done
  echo "    ],"
}

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

perl -i -pe "BEGIN{undef $/;} s/  const workflowManifests: Record<string, string\[\]> = \{.*?  \};/$(cat $temp_manifest | sed 's/\//\\\//g' | tr '\n' '§' | sed 's/§/\\n/g')/s" "$PARSER_FILE"

rm "$temp_manifest"

echo "      ✓ Story manifests updated in storyParser.ts"
echo ""

# ===========================================================================
# Step 2: Build Frontend
# ===========================================================================
echo "[2/3] Building frontend..."
cd "$PROJECT_ROOT/frontend"

# Clean previous build to avoid stale artifacts
echo "      Cleaning previous build..."
rm -rf dist/

# Build fresh frontend
pnpm run build
echo "      ✓ Frontend built: frontend/dist/"
echo ""

# ===========================================================================
# Step 3: Build Rust Backend (with embedded frontend)
# ===========================================================================
echo "[3/3] Building Rust backend..."
cd "$PROJECT_ROOT"

# Clean server package cache to force RustEmbed to re-embed the frontend
# This is more reliable than just touching files
echo "      Cleaning server cache..."
cargo clean -p server

cargo build --release
echo "      ✓ Backend built: target/release/server"
echo ""

# ===========================================================================
# Summary
# ===========================================================================
echo "╔════════════════════════════════════════════════════════╗"
echo "║                  BUILD COMPLETE                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Build artifacts:"
echo "  • Backend:  target/release/server ($(du -h target/release/server | cut -f1))"
echo "  • Frontend: frontend/dist/ ($(du -sh frontend/dist | cut -f1))"
echo "  • Stories:  $(find frontend/dist/stories -name "*.md" | wc -l | tr -d ' ') markdown files embedded"
echo ""
echo "To run Vibe Kanban:"
echo "  ./target/release/server"
echo ""
echo "To build the installer:"
echo "  ./build-installer.sh"
echo ""
