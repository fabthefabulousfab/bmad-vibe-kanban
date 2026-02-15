# Story 3-1/4: Generate Project Context

**Wave:** 3 | **Epic:** 1 | **Story:** 4
**Status:** Ready for Development

## User Story

**As a** developer documenting an existing project,
**I want** to generate a project-context.md file with critical rules and patterns,
**So that** AI agents maintain consistency when working with the codebase.

## Acceptance Criteria

1. [ ] project-context.md file generated from existing code
2. [ ] Detected patterns and conventions documented
3. [ ] Critical rules extracted from codebase
4. [ ] File format optimized for LLM consumption

## BMAD Workflow

**Command:**
```bash
claude "_bmad/bmm/workflows/document-project/generate-project-context/workflow.md"
```

**Input:**
- Existing project codebase
- `.claude/CLAUDE.md` (if exists)
- Architecture documentation (if exists)

**Output:** `project-context.md` (project root)

**Validation:** File contains detected rules, patterns, and constraints for AI agents

**Note:** This LLM-optimized file extracts existing patterns from the brownfield codebase to ensure AI agents respect established conventions when making changes.

### Checklist
- [ ] Command executed
- [ ] project-context.md created
- [ ] File reviewed and validated

## Definition of Done
- [ ] project-context.md in project root
- [ ] Contains detected patterns from codebase
- [ ] AI agents can use it for consistent modifications
- [ ] File included in version control
