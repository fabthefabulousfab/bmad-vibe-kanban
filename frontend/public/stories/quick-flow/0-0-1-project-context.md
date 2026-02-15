# Story 0-0/1: Generate Project Context

**Wave:** 0 | **Epic:** 0 | **Story:** 1
**Status:** Ready for Development

## User Story

**As a** developer using quick-flow,
**I want** to generate a project-context.md file with critical rules and patterns,
**So that** AI agents maintain consistency during feature development.

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
- Existing project codebase
- `.claude/CLAUDE.md` (if exists)
- Architecture documentation (if exists)
- PRD or README (if exists)

**Output:** `project-context.md` (project root)

**Validation:** File contains rules, patterns, and constraints for AI agents

**Note:** This LLM-optimized file ensures consistent code generation across all agents working on quick features. Generate this BEFORE implementing features to establish development guidelines.

### What Gets Captured

**Critical Rules:**
- Code style and formatting conventions
- Naming patterns (files, functions, variables)
- Error handling patterns
- Testing requirements

**Architecture Patterns:**
- Project structure
- Module organization
- Data flow patterns
- API patterns

**Constraints:**
- Performance requirements
- Security policies
- Compatibility requirements
- Third-party dependencies

### Checklist
- [ ] Command executed
- [ ] project-context.md created in project root
- [ ] File reviewed and validated
- [ ] Contains actionable rules for AI agents

## Definition of Done
- [ ] project-context.md in project root
- [ ] Contains detected patterns from codebase
- [ ] AI agents can use it for consistent feature development
- [ ] File included in version control
