# Story 1-2/0: ATDD - Write Tests First

**Wave:** 1 | **Epic:** 2 | **Story:** 0
**Status:** Ready for Development

## User Story

**As a** solo developer with a quick spec,
**I want** to write acceptance tests first,
**So that** I have failing tests before implementation (RED phase).

## Acceptance Criteria

1. [ ] Test file created for feature
2. [ ] Tests cover all acceptance criteria
3. [ ] Tests run and FAIL (RED)
4. [ ] Test structure matches spec

## BMAD Workflow

**Command:** `tea -> atdd`
**Input:** Quick spec
**Output:** `tests/features/{feature}/*.spec.ts`
**Validation:** `npm test` shows all new tests failing (RED)

### Checklist
- [ ] Command executed
- [ ] Output files generated
- [ ] Tests fail as expected (RED)

## Definition of Done
- [ ] All acceptance criteria have tests
- [ ] Tests fail before implementation
- [ ] Test coverage planned
