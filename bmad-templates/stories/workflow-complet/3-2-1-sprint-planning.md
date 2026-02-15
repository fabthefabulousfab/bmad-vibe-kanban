# Story 3-2/1: Sprint Planning

**Wave:** 3 | **Epic:** 2 | **Story:** 1
**Status:** Ready for Development

## User Story

**As a** solo developer with epics and stories,
**I want** to plan my sprints,
**So that** I have a clear development roadmap.

## Acceptance Criteria

1. [ ] Stories prioritized by value and risk
2. [ ] Sprint 0 stories identified
3. [ ] MVP stories grouped
4. [ ] Dependencies mapped

## BMAD Workflow

**Command:**
```bash
claude "_bmad/bmm/workflows/4-implementation/sprint-planning/workflow.md"
```

**Input:** Epics document
**Output:** `_bmad-output/implementation-artifacts/sprint-status.yaml`
**Validation:** Sprint status file contains all stories with statuses

### Follow-up
After sprint-planning, run create-story for each story:
```bash
claude "_bmad/bmm/workflows/4-implementation/create-story/workflow.md"
```
This generates complete story files with embedded ATDD, dev steps, and review checklists.

**Note:** check-implementation-readiness is run separately before this to validate planning artifacts are complete.

### Checklist
- [ ] Command executed
- [ ] Output files generated
- [ ] Validation passed

## Definition of Done
- [ ] Sprint plan created
- [ ] Sprint 0 clearly defined
- [ ] MVP scope identified
- [ ] Critical path understood
