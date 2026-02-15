# Story 1-2/0: ATDD - Write Failing Test for Bug

**Wave:** 1 | **Epic:** 2 | **Story:** 0
**Status:** Ready for Development

## User Story

**As a** solo developer with a bug spec,
**I want** to write a test that reproduces the bug,
**So that** I have a failing test proving the bug exists (RED phase).

## Acceptance Criteria

1. [ ] Test file created for bug reproduction
2. [ ] Test reproduces the bug reliably
3. [ ] Test runs and FAILS (RED)
4. [ ] Test will pass when bug is fixed

## BMAD Workflow

**Command:** `tea -> atdd`
**Input:** Bug spec
**Output:** `tests/bugs/{issue}/*.spec.ts`
**Validation:** `npm test` shows new test failing (RED)

### Checklist
- [ ] Command executed
- [ ] Output files generated
- [ ] Test fails as expected (RED)

## Definition of Done
- [ ] Bug reproduction test exists
- [ ] Test fails before fix
- [ ] Test designed to pass after fix
