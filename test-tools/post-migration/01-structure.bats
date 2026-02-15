#!/usr/bin/env bats
# Test 1: Repository Structure Validation

@test "Vibe Kanban fork structure exists" {
  [ -d "frontend" ]
  [ -d "crates" ]
  [ -d "npx-cli" ]
  [ -d "shared" ]
}

@test "BMAD templates structure exists" {
  [ -d "bmad-templates/stories" ]
  [ -d "bmad-templates/_bmad" ]
  [ -d "bmad-templates/scripts" ]
  [ -d "bmad-templates/templates" ]
  [ -d "bmad-templates/.claude" ]
}

@test "Build scripts exist and are executable" {
  [ -x "scripts/sync-stories.sh" ]
  [ -x "scripts/build-vibe-kanban.sh" ]
  [ -x "scripts/build-installer.sh" ]
  [ -x "scripts/check-story-freshness.sh" ]
}

@test "Story workflow templates are complete" {
  [ -d "bmad-templates/stories/workflow-complet" ]
  [ -d "bmad-templates/stories/quick-flow" ]
  [ -d "bmad-templates/stories/document-project" ]
  [ -d "bmad-templates/stories/debug" ]

  # Verify workflow-complet has stories
  workflow_count=$(find bmad-templates/stories/workflow-complet -name "*.md" -not -name "X-*" | wc -l)
  [ "$workflow_count" -ge 18 ]
}

@test "BMAD methodology docs exist" {
  [ -d "bmad-templates/_bmad" ]
  [ -f "bmad-templates/VERSION" ]
}

@test "Templates exist" {
  [ -d "bmad-templates/templates" ]
  [ -f "bmad-templates/templates/HOW TO - BMAD-VIBE-KANBAN.md" ]
}

@test "Claude Code configuration exists" {
  [ -d "bmad-templates/.claude" ]
  [ -f "bmad-templates/.claude/CLAUDE.md" ]
}

@test "Documentation structure exists" {
  [ -d "docs" ]
}

@test "Test directory structure exists" {
  [ -d "test-tools/post-migration" ]
}

@test "Gitignore includes BMAD patterns" {
  grep -q "_bmad-output" .gitignore
  grep -q "dist/" .gitignore
}

@test "Original VK README preserved" {
  [ -f "README-VK-ORIGINAL.md" ]
}

@test "New README exists" {
  [ -f "README.md" ]
  grep -q "BMAD Vibe Kanban" README.md
  grep -q "fork of Vibe Kanban 0.1.4" README.md
}
