# Story 3-2/0: Create Epics and Stories

**Wave:** 3 | **Epic:** 2 | **Story:** 0
**Status:** Ready for Development

## User Story

**As a** solo developer with all planning artifacts,
**I want** to break down requirements into epics and stories,
**So that** I have implementable work items for development.

## Acceptance Criteria

1. [ ] Epics designed around user value
2. [ ] Stories created for each epic
3. [ ] FR coverage map complete (all FRs mapped)
4. [ ] Stories sized for single dev agent

## BMAD Workflow

**Command:**
```bash
claude "_bmad/bmm/workflows/3-solutioning/create-epics-and-stories/workflow.md"
```

**Input:** PRD, Architecture
**Output:** `_bmad-output/planning-artifacts/epics.md`
**Validation:** All FRs covered, stories have acceptance criteria

### Checklist
- [ ] Command executed
- [ ] Output files generated
- [ ] Validation passed

## Definition of Done
- [ ] Epics document created
- [ ] 100% FR coverage
- [ ] Each story has Given/When/Then acceptance criteria
- [ ] Stories are independently implementable
