# Fork Information

This repository is a fork of **Vibe Kanban v0.1.4** with integrated BMAD (Build-Manage-Analyze-Deploy) framework.

## Upstream Information

- **Original Repository:** [github.com/BloopAI/vibe-kanban](https://github.com/BloopAI/vibe-kanban)
- **Fork Point:** v0.1.4 (February 2026)
- **Original License:** MIT
- **Original Author:** BloopAI

## What's Different from Upstream

### Additions

1. **bmad-templates/** - Complete BMAD framework
   - Story templates (workflow-complet, quick-flow, document-project, debug)
   - BMAD methodology documentation (_bmad/)
   - Workflow scripts and tooling
   - Claude Code configuration

2. **scripts/** - Build automation
   - `sync-stories.sh` - Sync templates to frontend
   - `check-story-freshness.sh` - Detect modifications
   - `build-vibe-kanban.sh` - Build with auto-sync
   - `build-installer.sh` - Self-extracting installer generator

3. **test-tools/post-migration/** - Migration validation tests

4. **docs/** - Enhanced documentation structure

### Modifications

1. **frontend/public/stories/** - Synced from bmad-templates at build time
2. **frontend/src/services/storyParser.ts** - Updated manifests for BMAD stories
3. **.gitignore** - Added BMAD-specific patterns
4. **README.md** - Documented fork and BMAD integration

### No Changes to Core VK Functionality

- All original Vibe Kanban features remain unchanged
- Backend (Rust) unmodified except for story serving
- Frontend UI unmodified except for story content
- API and MCP integration unchanged

## Syncing with Upstream

To pull updates from upstream Vibe Kanban:

```bash
# Add upstream remote (one time)
git remote add upstream https://github.com/BloopAI/vibe-kanban.git

# Fetch upstream changes
git fetch upstream

# Merge upstream changes into your branch
git merge upstream/main

# Resolve conflicts (typically in modified files only):
# - frontend/src/services/storyParser.ts
# - frontend/public/stories/
# - README.md
```

**Note:** Since bmad-templates/ is entirely new, upstream merges should not conflict with BMAD additions.

## Maintaining the Fork

### When Upstream Updates

1. Check upstream release notes
2. Fetch and merge upstream/main
3. Resolve conflicts (minimal - only in modified files)
4. Test build: `./scripts/build-vibe-kanban.sh`
5. Test installer: `./scripts/build-installer.sh`

### When Modifying Stories

1. Edit stories in `bmad-templates/stories/`
2. Run sync: `./scripts/sync-stories.sh`
3. Build: `./scripts/build-vibe-kanban.sh`
4. Stories automatically copied to frontend

### File Ownership

- **Upstream owns:** `frontend/`, `crates/`, `npx-cli/`, `shared/`
- **We own:** `bmad-templates/`, `scripts/` (build scripts), `test-tools/post-migration/`
- **Shared:** `.gitignore`, `README.md` (merge carefully)

## Contributing Back to Upstream

If you want to contribute VK improvements back to upstream:

1. Create a branch without BMAD additions
2. Cherry-pick only VK-related commits
3. Submit PR to BloopAI/vibe-kanban

Do not submit BMAD-specific changes to upstream.

## Version Numbering

This fork uses its own versioning:
- **Upstream version:** 0.1.4
- **BMAD fork version:** Defined in `bmad-templates/VERSION`
- **Combined notation:** `bmad-vibe-kanban-vX.Y.Z-vk0.1.4`

## License

This fork maintains the MIT license of the original Vibe Kanban project.
All BMAD additions are also MIT licensed.

## Credits

- **Vibe Kanban:** BloopAI (original project)
- **BMAD Framework:** Fabrice (@fabulousfab)
- **Integration:** Built with Claude Sonnet 4.5
