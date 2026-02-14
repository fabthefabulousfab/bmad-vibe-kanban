# Story 3-1/3: Workflow Transition

**Wave:** 3 | **Epic:** 1 | **Story:** 3
**Status:** Ready for Development

## User Story

**As a** developer who has documented an existing project,
**I want** to choose the next workflow based on my needs,
**So that** I continue with appropriate process for my next task.

## Acceptance Criteria

1. [ ] Documentation phase complete (PRD, Architecture, Test Design, NFR Assessment)
2. [ ] Decision made on next workflow
3. [ ] Appropriate workflow imported to Vibe Kanban

## BMAD Workflow

**Command:** `import-bmad-workflow.sh` (select next workflow)
**Input:** Completed documentation artifacts
**Output:** New workflow stories imported

### Decision Tree

```
After DOCUMENT_PROJECT completion:
    │
    ├─→ Adding a small feature?
    │   └─→ Select QUICK_FLOW
    │
    ├─→ Starting full development cycle?
    │   └─→ Select WORKFLOW_COMPLET (Phase 3 onwards)
    │
    └─→ Fixing a bug?
        └─→ Select DEBUG
```

### Checklist
- [ ] All Phase 0-3 documentation complete
- [ ] Next workflow selected
- [ ] New workflow stories imported

## Definition of Done
- [ ] DOCUMENT_PROJECT workflow complete
- [ ] Transition to next workflow initiated
- [ ] No orphaned tasks remaining
