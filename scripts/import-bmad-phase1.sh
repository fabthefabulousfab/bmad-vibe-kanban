#!/bin/bash
# Import BMAD Phase 1 (Analysis) workflows as Vibe Kanban tasks
# Run this after starting Vibe Kanban with: pnpm run dev
#
# These tasks are formatted for AUTO-EXECUTION:
# When a workspace starts, Claude Code will immediately execute the BMAD workflow.

set -e

# Configuration - adjust port if needed
BACKEND_PORT="${BACKEND_PORT:-3001}"
API_BASE="http://127.0.0.1:${BACKEND_PORT}/api"

echo "🔍 Checking Vibe Kanban backend on port ${BACKEND_PORT}..."

# Check if backend is running
if ! curl -s "${API_BASE}/health" > /dev/null 2>&1; then
    echo "❌ Backend not running. Start Vibe Kanban first with: pnpm run dev"
    echo "   Then re-run this script."
    exit 1
fi

echo "✅ Backend is running"

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed. Install with: brew install jq"
    exit 1
fi

# Step 1: Create the BMAD Integration project
echo ""
echo "📁 Creating project 'BMAD Integration'..."

PROJECT_PATH="$(pwd)"

PROJECT_RESPONSE=$(curl -s -X POST "${API_BASE}/projects" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
        --arg name "BMAD Integration" \
        --arg display_name "BMAD Integration" \
        --arg git_repo_path "$PROJECT_PATH" \
        '{
            name: $name,
            repositories: [{
                display_name: $display_name,
                git_repo_path: $git_repo_path
            }]
        }')")

PROJECT_ID=$(echo "$PROJECT_RESPONSE" | jq -r '.data.id // empty')

if [ -z "$PROJECT_ID" ]; then
    echo "⚠️  Could not create project. It may already exist."
    echo "   Trying to find existing project..."

    PROJECTS=$(curl -s "${API_BASE}/projects")
    PROJECT_ID=$(echo "$PROJECTS" | jq -r '.data[0].id // empty')

    if [ -z "$PROJECT_ID" ]; then
        echo "❌ No project found. Please create a project manually in Vibe Kanban."
        exit 1
    fi
    echo "   Found project ID: $PROJECT_ID"
fi

echo "✅ Project ID: $PROJECT_ID"

# Step 2: Create Phase 1 tasks with AUTO-EXECUTION format
echo ""
echo "📝 Creating Phase 1 (Analysis) tasks..."

# ============================================================================
# Task 1: Product Brief
# ============================================================================
echo "   Creating: Phase 1.1 - Product Brief (Analyst)..."

TASK1_DESC='INSTRUCTION: Execute this BMAD workflow command immediately upon starting this workspace:

/bmad:bmm:workflows:create-product-brief

---

## Context

You are the BMAD **Analyst** agent. Your mission is to create a Product Brief that defines the vision and scope for integrating BMAD methodology into Vibe Kanban.

## Expected Deliverables

- `_bmad-output/planning-artifacts/product-brief.md`

## Acceptance Criteria

When the workflow completes, ensure:
- [ ] Product vision is clearly defined
- [ ] Target users are identified
- [ ] Success metrics are established
- [ ] Scope and boundaries are clarified

## Integration Goal

We want to integrate BMAD workflows into Vibe Kanban so that:
1. BMAD stories are auto-imported at launch
2. Each story executes its corresponding BMAD workflow
3. Full test coverage via dev-story workflow'

TASK1_RESPONSE=$(curl -s -X POST "${API_BASE}/tasks" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
        --arg project_id "$PROJECT_ID" \
        --arg title "Phase 1.1 - Product Brief" \
        --arg description "$TASK1_DESC" \
        '{
            project_id: $project_id,
            title: $title,
            description: $description
        }')")

TASK1_ID=$(echo "$TASK1_RESPONSE" | jq -r '.data.id // empty')
if [ -z "$TASK1_ID" ]; then
    echo "   ⚠️  Warning: Could not create task. Response: $TASK1_RESPONSE"
else
    echo "   ✅ Created task: $TASK1_ID"
fi

# ============================================================================
# Task 2: Research
# ============================================================================
echo "   Creating: Phase 1.2 - Research (Analyst)..."

TASK2_DESC='INSTRUCTION: Execute this BMAD workflow command immediately upon starting this workspace:

/bmad:bmm:workflows:research

---

## Context

You are the BMAD **Analyst** agent. Your mission is to conduct comprehensive research on integration patterns and user needs.

## Research Types to Explore

- **Market Research**: Understand similar AI-assisted project management tools
- **Technical Research**: CLI/UI integration patterns, agent orchestration
- **Domain Research**: AI-first project management methodologies

## Expected Deliverables

- `_bmad-output/planning-artifacts/research-market.md`
- `_bmad-output/planning-artifacts/research-technical.md`
- `_bmad-output/planning-artifacts/research-domain.md`

## Acceptance Criteria

When the workflow completes, ensure:
- [ ] Market analysis is complete
- [ ] Technical patterns are identified
- [ ] Recommendations are documented

## Focus Areas

1. How do similar tools handle AI agent orchestration?
2. What patterns exist for CLI-to-UI workflow integration?
3. Best practices for BMAD-style methodology automation'

TASK2_RESPONSE=$(curl -s -X POST "${API_BASE}/tasks" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
        --arg project_id "$PROJECT_ID" \
        --arg title "Phase 1.2 - Research" \
        --arg description "$TASK2_DESC" \
        '{
            project_id: $project_id,
            title: $title,
            description: $description
        }')")

TASK2_ID=$(echo "$TASK2_RESPONSE" | jq -r '.data.id // empty')
if [ -z "$TASK2_ID" ]; then
    echo "   ⚠️  Warning: Could not create task. Response: $TASK2_RESPONSE"
else
    echo "   ✅ Created task: $TASK2_ID"
fi

echo ""
echo "✅ Phase 1 tasks created successfully!"
echo ""
echo "📋 How it works:"
echo "   1. Open Vibe Kanban in your browser"
echo "   2. Select the 'BMAD Integration' project"
echo "   3. Open 'Phase 1.1 - Product Brief'"
echo "   4. Start a Workspace with Claude Code as the agent"
echo "   5. ⚡ The BMAD workflow executes AUTOMATICALLY"
echo ""
echo "🚀 The agent will see 'INSTRUCTION: Execute this BMAD workflow command immediately'"
echo "   and will run /bmad:bmm:workflows:create-product-brief without user intervention."
echo ""
