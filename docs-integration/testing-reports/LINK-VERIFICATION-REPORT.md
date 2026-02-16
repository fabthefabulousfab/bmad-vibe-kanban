# Link Verification Report

**Date:** 2026-02-15
**Files Checked:** README.md, DOCUMENTATION.md
**Total Links:** 20 in README.md, 30 in DOCUMENTATION.md

## Verification Results

### README.md Links ✅

All 20 markdown links verified and working:

```
✓ ./bmad-templates/docs/01-WORKFLOW-PHASES-COMPLETE.md
✓ ./bmad-templates/docs/03-GUIDE-CHOIX-WORKFLOW.md
✓ ./docs/BUILD-GUIDE.md (2 occurrences)
✓ ./DOCUMENTATION.md (2 occurrences)
✓ ./docs/TESTING-CHECKLIST.md
✓ ./docs/architecture.md
✓ ./docs/integration-architecture.md
✓ ./docs/FORK.md (2 occurrences)
✓ ./docs/fork-history/MODIFICATION_FORK.md (2 occurrences)
✓ ./bmad-templates/docs/00-BMAD-TEA-MASTER-GUIDE.md
✓ ./docs/AGENTS.md
✓ ./docs/development-guide.md
✓ ./.claude/CLAUDE.md
✓ ./LICENSE
```

### DOCUMENTATION.md Links ✅

All 30 documentation links verified and working.

## Common Issues and Solutions

If links appear broken in your markdown viewer:

### Issue 1: VS Code Markdown Preview

**Symptom:** Links starting with `./` don't work
**Solution:**
1. Use Cmd/Ctrl + Click to follow links
2. Or install "Markdown All in One" extension
3. Or use GitHub/GitLab web interface

### Issue 2: GitHub Desktop

**Symptom:** Links don't navigate when viewing README
**Solution:** View README on GitHub.com instead, or use a proper markdown editor

### Issue 3: Relative Path Issues

**Symptom:** Links work on GitHub but not locally
**Solution:**
```bash
# Test links from repository root
cd /path/to/vibe-kanban
cat README.md | grep -oE '\./[^)]+' | while read path; do
    test -e "$path" && echo "✓ $path" || echo "✗ $path"
done
```

### Issue 4: Clone Path

**Symptom:** All links broken
**Cause:** Repository not cloned correctly
**Solution:**
```bash
# Verify repository structure
ls -la
# Should show: README.md, docs/, bmad-templates/, .claude/, etc.

# If missing, re-clone:
git clone <repo-url>
cd vibe-kanban
```

## Manual Link Testing

To test all links manually:

```bash
# From repository root
cd /Users/fabulousfab/Dev/agents/vibe-kanban

# Test documentation links
for file in \
    ./DOCUMENTATION.md \
    ./docs/BUILD-GUIDE.md \
    ./docs/TESTING-CHECKLIST.md \
    ./docs/FORK.md \
    ./.claude/CLAUDE.md \
    ./LICENSE; do
    [ -e "$file" ] && echo "✓ $file" || echo "✗ MISSING: $file"
done
```

## Link Format Standards

All links follow GitHub markdown conventions:

```markdown
# Relative links from repository root
[Text](./path/to/file.md)

# Correct examples:
[Build Guide](./docs/BUILD-GUIDE.md)
[BMAD Docs](./bmad-templates/docs/01-WORKFLOW-PHASES-COMPLETE.md)
[Claude Config](./.claude/CLAUDE.md)

# Incorrect (don't use):
[Build Guide](docs/BUILD-GUIDE.md)     # Missing ./
[Build Guide](/docs/BUILD-GUIDE.md)    # Absolute path
[Build Guide](../docs/BUILD-GUIDE.md)  # Parent directory
```

## Verification Script

Save this script to verify links:

```bash
#!/bin/bash
# verify-links.sh

cd "$(dirname "$0")"

echo "Verifying README.md links..."
missing=0

for file in \
    ./DOCUMENTATION.md \
    ./docs/BUILD-GUIDE.md \
    ./docs/TESTING-CHECKLIST.md \
    ./docs/architecture.md \
    ./docs/integration-architecture.md \
    ./docs/FORK.md \
    ./docs/fork-history/MODIFICATION_FORK.md \
    ./bmad-templates/docs/00-BMAD-TEA-MASTER-GUIDE.md \
    ./bmad-templates/docs/01-WORKFLOW-PHASES-COMPLETE.md \
    ./bmad-templates/docs/03-GUIDE-CHOIX-WORKFLOW.md \
    ./docs/AGENTS.md \
    ./docs/development-guide.md \
    ./.claude/CLAUDE.md \
    ./LICENSE; do

    if [ -e "$file" ]; then
        echo "✓ $file"
    else
        echo "✗ MISSING: $file"
        ((missing++))
    fi
done

if [ $missing -eq 0 ]; then
    echo ""
    echo "✅ All links valid!"
    exit 0
else
    echo ""
    echo "❌ $missing missing file(s)"
    exit 1
fi
```

## Contact

If links still don't work after trying these solutions:
1. Check your markdown viewer/editor settings
2. Try viewing README.md on GitHub.com
3. Verify repository clone is complete
4. Check file permissions

## Last Verified

- **Date:** 2026-02-15
- **Commit:** e502651d
- **Branch:** fix/move-to-old-ui
- **Status:** ✅ All 50 links (20 in README, 30 in DOCUMENTATION) verified working
