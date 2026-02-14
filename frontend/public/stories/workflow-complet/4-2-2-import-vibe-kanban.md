# Story 4-2/2: Import Stories to Vibe Kanban

**Wave:** 4 | **Epic:** 2 | **Story:** 2
**Status:** Ready for Development

## User Story

**As a** developer with wave-organized stories,
**I want** to import all stories into Vibe Kanban,
**So that** I can track progress visually and manage my development workflow.

## Acceptance Criteria

1. [ ] Vibe Kanban running and accessible
2. [ ] Project created in Vibe Kanban (matching directory name)
3. [ ] All stories imported with sequential numbering
4. [ ] Stories appear in correct order (1, 2, 3...)
5. [ ] Full story content visible in task description

## BMAD Workflow

**Command:** `./scripts/import-bmad-workflow.sh --clean`
**Input:** Wave-organized story files in `stories/` directory
**Output:** Tasks created in Vibe Kanban project

### Import Process

```bash
# 1. Ensure Vibe Kanban is running
npx vibe-kanban

# 2. Run the import script (in your project directory)
./scripts/import-bmad-workflow.sh --clean

# 3. Select your workflow when prompted:
#    1) New project from scratch -> WORKFLOW_COMPLET
#    2) Document existing project -> DOCUMENT_PROJECT
#    3) Simple feature -> QUICK_FLOW
#    4) Complex feature -> WORKFLOW_COMPLET
#    5) Bug fix -> DEBUG
```

### Story Path by Wave

After import, stories are organized by waves. Execute them in order:

| Wave | Stories | Description |
|------|---------|-------------|
| Wave 1 | [1] - [3] | Analysis: Brainstorm, Research, Product Brief |
| Wave 2 | [4] - [5] | Planning: PRD, UX Design |
| Wave 3 | [6] - [11] | Solutioning: Architecture, Test Design, NFR, Epics, Sprint Planning |
| Wave 4 | [12] - [16] | Setup: Sprint 0 Framework, CI, Prepare Stories, Wave Planning, Import |
| Wave 5+ | Dynamic | Development: Story-by-story implementation |
| Final | [Last] | Release: Traceability verification |

### Within Each Wave

```
Wave N
├── Story N.1 (can run in parallel with N.2, N.3...)
├── Story N.2 (can run in parallel with N.1, N.3...)
├── Story N.3 (can run in parallel with N.1, N.2...)
└── FIN EPIC (if epic boundary - must wait for all above)
```

### Vibe Kanban URL

After import, access your project at:
```
http://localhost:3001
```

### Checklist
- [ ] Vibe Kanban started
- [ ] Import script executed
- [ ] Workflow type selected
- [ ] Project created/selected
- [ ] All stories imported
- [ ] Order verified in backlog

## Definition of Done
- [ ] All stories visible in Vibe Kanban
- [ ] Stories numbered sequentially [1], [2], [3]...
- [ ] Stories appear in correct order
- [ ] Full content accessible in task descriptions
- [ ] BMAD-WORKFLOW.md created in project root
