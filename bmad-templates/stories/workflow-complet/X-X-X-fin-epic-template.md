# Story X-X/X: FIN EPIC - [Epic Name]

**Wave:** X | **Epic:** X | **Story:** X (last in epic)
**Status:** TEMPLATE
**Type:** FIN EPIC (Epic Completion Story)
**Note:** Copy and customize for each epic. Replace X with actual numbers.

## User Story

**As a** developer completing an epic,
**I want** to validate coverage, NFRs, and capture lessons learned,
**So that** the epic is properly closed before moving to the next.

## Acceptance Criteria

1. [ ] EE.1 automate: Coverage gaps identified and addressed
2. [ ] EE.2 nfr-assess: All NFRs validated (PASS or WAIVED)
3. [ ] EE.3 retrospective: Lessons learned documented

## BMAD Workflow

### EE.1 tea -> automate
**Command:** `claude "_bmad/tea/workflows/testarch/automate/workflow.md"`
**Output:** `_bmad-output/reviews/epic-{N}-automate.md`
**Validation:** Coverage >= 80%, gaps addressed

```
Purpose: Combler lacunes couverture
- Analyze test coverage for all epic stories
- Identify untested functions/branches
- Add missing tests or document waivers
```

### EE.2 tea -> nfr-assess
**Command:** `claude "_bmad/tea/workflows/testarch/nfr-assess/workflow.md"`
**Output:** `_bmad-output/reviews/epic-{N}-nfr-assess.md`
**Validation:** All NFRs PASS or WAIVED with justification

```
Purpose: Validation NFRs
- Review each applicable NFR
- Collect evidence of compliance
- Document PASS/WAIVED/FAIL status
- No FAIL allowed for epic completion
```

### EE.3 retrospective
**Command:** `retrospective`
**Output:** `_bmad-output/reviews/epic-{N}-retrospective.md`
**Validation:** Document created and reviewed

```
Purpose: Retour d'experience
- What went well?
- What could be improved?
- Technical debt identified
- Recommendations for next epic
```

### Checklist
- [ ] EE.1 automate complete
- [ ] EE.2 nfr-assess PASS/WAIVED
- [ ] EE.3 retrospective documented
- [ ] Epic artifacts archived

## Definition of Done
- [ ] All EE steps complete
- [ ] No FAIL NFRs
- [ ] Retrospective shared with team
- [ ] Ready for next epic

---

## Usage Instructions

This is a **template**. For each epic completion:

1. Copy this file to appropriate wave folder
2. Rename: `{W}-{E}-{S}-fin-epic-{epic-name}.md`
3. Update Wave/Epic/Story numbers
4. Replace `[Epic Name]` with actual epic name
5. Replace `{N}` with epic number in output paths

### Example

For Epic 2 completion in Wave 5:
- Filename: `5-2-9-fin-epic-workflow-import.md`
- Wave: 5 | Epic: 2 | Story: 9
