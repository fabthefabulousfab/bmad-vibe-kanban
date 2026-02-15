# Story 4-3/0: Create Complete Story Files

**Wave:** 4 | **Epic:** 3 | **Story:** 0
**Status:** Ready for Development

## User Story

**As a** developer with sprint-status.yaml,
**I want** to generate complete story files for each story,
**So that** each file contains embedded ATDD, implementation tasks, and review checklists.

## Acceptance Criteria

1. [ ] Story files generated for all stories in sprint-status.yaml
2. [ ] Each file contains embedded ATDD test specifications
3. [ ] Each file contains implementation workflow steps
4. [ ] Each file contains code-review and test-review checklists
5. [ ] Files ready for Vibe Kanban import

## BMAD Workflow

**Command:** (for each story in sprint-status.yaml)
```bash
claude "_bmad/bmm/workflows/4-implementation/create-story/workflow.md"
```

**Input:**
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (from Story 3-2/1)
- `_bmad-output/planning-artifacts/epics.md`
- `_bmad-output/planning-artifacts/architecture.md`

**Output:** `_bmad-output/implementation-artifacts/stories/`
- Complete story files (e.g., `1-1-0-user-authentication.md`)
- Each containing full lifecycle (ATDD, dev, review, trace)

**Validation:** Generated story files are self-contained and executable

### Story File Structure

Each generated story contains:

```markdown
# Story X-Y/Z: [Title]

## User Story
[As a / I want / So that]

## Acceptance Criteria
[Given/When/Then]

## ATDD Test Specifications
[Test descriptions with Given/When/Then]
[Test scaffolds in target framework]

## Implementation Workflow

### Step 1: RED Phase (ATDD)
- Tests already specified above
- Run tests: EXPECT RED (failing)

### Step 2: GREEN Phase (Implementation)
- Implement feature code
- Run tests: EXPECT GREEN (passing)

### Step 3: Code Review
- Use code-review workflow
- Address findings

### Step 4: Test Review
- Use test-review workflow
- Verify coverage

### Step 5: Trace
- Update traceability matrix
- Link requirements → tests → code
```

### Integration with testarch/atdd

The create-story workflow automatically integrates:
- **testarch/atdd** for generating test specifications
- Test-first approach (RED → GREEN → REFACTOR)
- Complete acceptance criteria coverage

### Checklist
- [ ] All stories from sprint-status.yaml processed
- [ ] Story files generated with ATDD embedded
- [ ] Files validated as self-contained
- [ ] Ready for import to Vibe Kanban

## Definition of Done
- [ ] Complete story files created for sprint
- [ ] Each story is self-contained
- [ ] ATDD tests embedded in each file
- [ ] Files ready for Story 4-2/0 (import-vibe-kanban)
