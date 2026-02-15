# Story 0-0/0: BMAD Framework Setup

**Wave:** 0 | **Epic:** 0 | **Story:** 0
**Status:** Ready for Development

## User Story

**As a** developer starting with BMAD,
**I want** to initialize the BMAD framework in my project,
**So that** all workflows have the required directory structure and configuration.

## Acceptance Criteria

1. [ ] `_bmad` directory structure created
2. [ ] `config.yaml` template copied to project root
3. [ ] Output folders created (`_bmad-output/planning-artifacts`, etc.)
4. [ ] Prerequisites verified (Claude Code CLI, jq, git)

## BMAD Workflow

**Type:** Manual Setup Task

**Process:**
1. Create directory structure:
```bash
mkdir -p _bmad-output/{planning-artifacts,implementation-artifacts,reviews}
mkdir -p docs/{input,brief,prd,architecture,design,epics-stories-tasks,test,test-results}
mkdir -p test-tools scripts prompts configs
```

2. Copy BMAD config template (if not exists):
```bash
if [ ! -f config.yaml ]; then
    cp _bmad/config.yaml.template config.yaml
fi
```

3. Verify prerequisites:
```bash
command -v claude >/dev/null || echo "Install Claude Code CLI"
command -v jq >/dev/null || echo "Install jq"
git --version >/dev/null || echo "Install git"
```

4. Initialize git (if not already):
```bash
git init
git add .
git commit -m "feat: initialize BMAD framework"
```

**Output:**
- Project structure with all required directories
- `config.yaml` with BMAD configuration
- Git repository initialized

**Validation:** All directories exist and config.yaml is valid YAML

### Checklist
- [ ] Directory structure created
- [ ] config.yaml exists
- [ ] Prerequisites verified
- [ ] Git initialized

## Definition of Done
- [ ] BMAD framework ready for use
- [ ] All directories in place
- [ ] Configuration template available
- [ ] Prerequisites satisfied
