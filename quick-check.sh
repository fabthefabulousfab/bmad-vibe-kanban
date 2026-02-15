#!/usr/bin/env bash
# ===========================================================================
# Quick Check - Validate BMAD-Vibe-Kanban Setup
# ===========================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║        BMAD-Vibe-Kanban - Quick Validation Check             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

ERRORS=0

# Test 1: Directory Structure
echo "▶ Test 1: Directory Structure"
if [ -d "bmad-templates/stories" ] && [ -d "frontend" ] && [ -d "crates" ]; then
  echo "  ✓ Core directories present"
else
  echo "  ✗ Missing core directories"
  ERRORS=$((ERRORS + 1))
fi

# Test 2: Build Scripts
echo "▶ Test 2: Build Scripts"
if [ -x "./build-vibe-kanban.sh" ] && [ -x "./build-installer.sh" ]; then
  echo "  ✓ Build scripts executable"
else
  echo "  ✗ Build scripts missing or not executable"
  ERRORS=$((ERRORS + 1))
fi

# Test 3: Story Templates
echo "▶ Test 3: Story Templates"
story_count=$(find bmad-templates/stories -name "*.md" -not -name "X-*" 2>/dev/null | wc -l | tr -d ' ')
if [ "$story_count" -ge 35 ]; then
  echo "  ✓ Story templates present ($story_count files)"
else
  echo "  ✗ Insufficient stories ($story_count < 35)"
  ERRORS=$((ERRORS + 1))
fi

# Test 4: Frontend Stories (if synced)
echo "▶ Test 4: Frontend Stories"
if [ -d "frontend/public/stories" ]; then
  frontend_count=$(find frontend/public/stories -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$frontend_count" -ge 35 ]; then
    echo "  ✓ Frontend stories synced ($frontend_count files)"
  else
    echo "  ⚠ Frontend stories may need sync ($frontend_count files)"
    echo "    Run: ./build-vibe-kanban.sh"
  fi
else
  echo "  ⚠ Frontend stories not yet synced"
  echo "    Run: ./build-vibe-kanban.sh"
fi

# Test 5: Story Parser Service
echo "▶ Test 5: Story Import Services"
if [ -f "frontend/src/services/storyParser.ts" ] && [ -f "frontend/src/services/storyImportService.ts" ]; then
  if grep -q "workflowManifests" frontend/src/services/storyParser.ts; then
    echo "  ✓ Story services present and configured"
  else
    echo "  ✗ Story manifests not configured"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ✗ Story services missing"
  ERRORS=$((ERRORS + 1))
fi

# Test 6: BMAD Structure
echo "▶ Test 6: BMAD Framework"
if [ -d "_bmad" ] && [ -d ".claude" ]; then
  echo "  ✓ BMAD native structure (_bmad/ and .claude/ at root)"
else
  echo "  ⚠ BMAD framework not at root (normal for build repo)"
fi

# Test 7: Build Output (if built)
echo "▶ Test 7: Build Artifacts"
if [ -f "target/release/server" ]; then
  binary_size=$(du -h target/release/server | cut -f1)
  echo "  ✓ Vibe Kanban binary built ($binary_size)"
else
  echo "  ⚠ Binary not built yet"
  echo "    Run: ./build-vibe-kanban.sh"
fi

if [ -f "dist/install-bmad-vibe-kanban.sh" ]; then
  installer_size=$(du -h dist/install-bmad-vibe-kanban.sh | cut -f1)
  echo "  ✓ Installer built ($installer_size)"
else
  echo "  ⚠ Installer not built yet"
  echo "    Run: ./build-installer.sh"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ]; then
  echo "✅ All checks passed! Repository is valid."
  echo ""
  echo "Next steps:"
  echo "  - To build: ./build-vibe-kanban.sh"
  echo "  - To create installer: ./build-installer.sh"
  echo "  - To test: ./target/release/server"
  echo "  - For detailed guide: cat BUILD-GUIDE.md"
  exit 0
else
  echo "❌ $ERRORS check(s) failed. Review errors above."
  exit 1
fi
