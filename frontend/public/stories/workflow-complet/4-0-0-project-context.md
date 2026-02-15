# Story 4-0/0: Generate Project Context

**Wave:** 4 | **Epic:** 0 | **Story:** 0
**Status:** Ready for Development

## User Story

**As a** developer starting implementation,
**I want** to generate a project-context.md file with critical rules and patterns,
**So that** AI agents maintain consistency across all code generation.

## Acceptance Criteria

1. [ ] project-context.md file generated
2. [ ] Critical coding rules documented
3. [ ] Architecture patterns captured
4. [ ] File format optimized for LLM consumption

## BMAD Workflow

**Command:**
```bash
claude "_bmad/bmm/workflows/generate-project-context/workflow.md"
```

**Input:**
- `_bmad-output/planning-artifacts/prd.md`
- `_bmad-output/planning-artifacts/architecture.md`
- Project codebase (if exists)

**Output:** `project-context.md` (project root)

**Validation:** File contains rules, patterns, and constraints for AI agents

**Note:** This LLM-optimized file ensures consistent code generation across all agents working on the project. Generate this BEFORE implementing stories to establish development guidelines.

### Checklist
- [ ] Command executed
- [ ] project-context.md created
- [ ] File reviewed and validated

## Definition of Done
- [ ] project-context.md in project root
- [ ] Contains critical rules and patterns
- [ ] AI agents can use it for consistent code generation
- [ ] File included in version control
