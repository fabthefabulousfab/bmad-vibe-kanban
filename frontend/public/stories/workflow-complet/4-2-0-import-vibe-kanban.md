# Story 4-2/0: Import Stories to Vibe Kanban

**Wave:** 4 | **Epic:** 2 | **Story:** 0
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

**Type:** UI-based Import (No command needed)

**Input:** Wave-organized story files in `stories/` directory (committed to git)
**Output:** Tasks created in Vibe Kanban project

### Import Process (UI-based)

```
1. Ensure Vibe Kanban is running
   - Installer auto-starts Vibe Kanban
   - Or start manually: npx vibe-kanban

2. Open Vibe Kanban in browser
   - URL: http://localhost:3001
   - Auto-opens after installation

3. Create or select project
   - Click "New Project" or select existing
   - Project name auto-detected from directory

4. Import stories via UI
   - Click orange "+" button in "To Do" column
   - Select workflow scenario:
     • workflow-complet: New project from scratch
     • document-project: Document existing project
     • quick-flow: Simple feature addition
   - Click "Execute" to import all stories

5. Stories imported automatically
   - All stories from selected scenario loaded
   - Sequential numbering [1], [2], [3]...
   - Full content visible in task cards
```

**Note:** The old CLI script (`import-bmad-workflow.sh`) is deprecated. Import is now done via Vibe Kanban UI for better user experience.

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

## Post-Import: Story Execution

After import, execute each story in Vibe Kanban using:
```bash
claude "_bmad/bmm/workflows/4-implementation/dev-story/workflow.md" --story_file {story_path}
```
This workflow handles ATDD execution, implementation, code-review, and story completion.
