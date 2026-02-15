#!/usr/bin/env bash
# ===========================================================================
# Quick Check Script - Validate migration basics
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║        BMAD Vibe Kanban - Quick Validation Check             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

ERRORS=0

# Test 1: Structure
echo "▶ Test 1: Structure"
if [ -d "bmad-templates/stories" ] && [ -d "scripts" ]; then
  echo "  ✓ Directory structure OK"
else
  echo "  ✗ Missing directories"
  ERRORS=$((ERRORS + 1))
fi

# Test 2: Scripts executable
echo "▶ Test 2: Build scripts"
if [ -x "scripts/sync-stories.sh" ] && [ -x "scripts/build-vibe-kanban.sh" ]; then
  echo "  ✓ Build scripts executable"
else
  echo "  ✗ Scripts not executable"
  ERRORS=$((ERRORS + 1))
fi

# Test 3: Story count
echo "▶ Test 3: Story templates"
story_count=$(find bmad-templates/stories -name "*.md" -not -name "X-*" | wc -l | tr -d ' ')
if [ "$story_count" -ge 39 ]; then
  echo "  ✓ Story templates present ($story_count files)"
else
  echo "  ✗ Insufficient stories ($story_count < 39)"
  ERRORS=$((ERRORS + 1))
fi

# Test 4: Frontend has stories
echo "▶ Test 4: Frontend stories"
if [ -d "frontend/public/stories/workflow-complet" ]; then
  frontend_count=$(find frontend/public/stories -name "*.md" | wc -l | tr -d ' ')
  if [ "$frontend_count" -ge 39 ]; then
    echo "  ✓ Frontend stories synced ($frontend_count files)"
  else
    echo "  ⚠ Frontend stories may need sync ($frontend_count files)"
    echo "    Run: ./scripts/sync-stories.sh"
  fi
else
  echo "  ✗ Frontend stories missing"
  ERRORS=$((ERRORS + 1))
fi

# Test 5: Manifest updated
echo "▶ Test 5: Story manifests"
if grep -q "0-0-0-bmad-setup" frontend/src/services/storyParser.ts; then
  echo "  ✓ Manifests updated (bmad-setup found)"
else
  echo "  ✗ Manifests not updated"
  ERRORS=$((ERRORS + 1))
fi

# Test 6: Documentation
echo "▶ Test 6: Documentation"
if [ -f "README.md" ] && [ -f "FORK.md" ] && [ -f "TESTING-CHECKLIST.md" ]; then
  echo "  ✓ Documentation complete"
else
  echo "  ✗ Missing documentation"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ]; then
  echo "✅ All checks passed! Migration is valid."
  echo ""
  echo "Next steps:"
  echo "  - For complete validation: see TESTING-CHECKLIST.md"
  echo "  - To build frontend: cd frontend && pnpm run build"
  echo "  - To sync stories: ./scripts/sync-stories.sh"
  echo "  - To build everything: ./scripts/build-vibe-kanban.sh"
  exit 0
else
  echo "❌ $ERRORS check(s) failed. Review errors above."
  exit 1
fi
