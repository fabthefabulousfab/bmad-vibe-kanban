# BMAD-Vibe-Kanban Build Guide

This guide explains how to build the BMAD-Vibe-Kanban project, which combines:
- **Vibe Kanban** fork (v0.1.4) - Kanban board with AI agent integration
- **BMAD Framework** - Build-Manage-Analyze-Deploy methodology with workflow stories

## Quick Start

```bash
# 1. Build Vibe Kanban with BMAD stories
./build-vibe-kanban.sh

# 2. Build the installer
./build-installer.sh

# 3. Test the installer
mkdir /tmp/test && cd /tmp/test
~/Dev/agents/vibe-kanban/dist/install-bmad-vibe-kanban.sh --help
```

## Project Structure

```
vibe-kanban/
├── bmad-templates/          # BMAD source (stories, scripts, docs)
│   ├── stories/             # 40 workflow story templates
│   ├── scripts/             # BMAD build and import scripts
│   ├── _bmad/               # BMAD framework source
│   └── .claude/             # Claude Code config source
├── frontend/                # Vibe Kanban React app
│   ├── public/stories/      # Stories synced from bmad-templates
│   └── src/services/
│       ├── storyParser.ts   # Story discovery and parsing
│       └── storyImportService.ts  # Import orchestration
├── crates/                  # Vibe Kanban Rust backend
├── target/release/server    # Compiled binary (after build)
└── dist/                    # Build outputs
    └── install-bmad-vibe-kanban.sh  # Self-extracting installer
```

## Build Process

### Step 1: Build Vibe Kanban

```bash
./build-vibe-kanban.sh
```

**What this does:**
1. **Syncs stories** from `bmad-templates/stories/` to `frontend/public/stories/`
2. **Updates manifests** in `frontend/src/services/storyParser.ts`
3. **Builds frontend** with Vite (includes stories in dist/)
4. **Compiles Rust backend** which embeds frontend/dist/ via RustEmbed

**Output:**
- `target/release/server` (117 MB) - Backend with embedded frontend and stories
- `frontend/dist/` - Frontend bundle with 40 story files

**Time:** ~2-3 minutes

### Step 2: Build Installer

```bash
./build-installer.sh
```

**Prerequisites:**
- Vibe Kanban must be built first (`./build-vibe-kanban.sh`)

**What this does:**
1. **Verifies** that Vibe Kanban binary exists
2. **Checks** that stories are synced (>30 files)
3. **Builds NPX package** (if needed)
4. **Creates installer** by calling `bmad-templates/scripts/build-installer.sh`
5. **Embeds binary** for current platform (macos-arm64 or macos-x64)

**Output:**
- `dist/install-bmad-vibe-kanban.sh` (55+ MB) - Self-extracting installer

**Time:** ~5-10 minutes (if rebuild needed)

## Story Management

### Adding/Modifying Stories

Stories are stored in `bmad-templates/stories/` organized by workflow:

```
bmad-templates/stories/
├── workflow-complet/    # 18 stories - Full project workflow
├── document-project/    # 10 stories - Documentation workflow
├── quick-flow/          # 4 stories  - Quick feature workflow
└── debug/               # 7 stories  - Bug fix workflow
```

**After modifying stories:**

```bash
# Rebuild to sync changes
./build-vibe-kanban.sh
```

The build script automatically:
1. Syncs stories to `frontend/public/stories/`
2. Updates the manifest in `storyParser.ts`
3. Rebuilds frontend with new stories
4. Compiles backend with updated frontend

### Story File Format

Stories use WES (Wave-Epic-Story) numbering:

```markdown
# Story 1-2/3: Story Title

**Wave:** 1 | **Epic:** 2 | **Story:** 3
**Status:** Ready for Development

## User Story
As a [role], I want [feature], so that [benefit].

## Acceptance Criteria
1. [ ] Criterion 1
2. [ ] Criterion 2
```

File naming: `{wave}-{epic}-{story}-{slug}.md`
Example: `1-2-3-implement-feature.md`

## Testing Builds

### Test Vibe Kanban Binary

```bash
# Run the compiled binary
./target/release/server

# Opens browser to http://127.0.0.1:{auto-port}
```

### Test Installer

```bash
# Create test directory
mkdir /tmp/test-install && cd /tmp/test-install

# Run installer with options
~/Dev/agents/vibe-kanban/dist/install-bmad-vibe-kanban.sh \
  --skip-deps \
  --no-autostart \
  --verbose

# Verify extraction
ls -la
# Expected: _bmad/, .claude/, stories/, scripts/, templates/
```

**Installer Options:**
- `--help` - Show usage
- `--skip-deps` - Skip system dependency installation
- `--skip-vibe` - Skip Vibe Kanban installation (extract BMAD only)
- `--no-autostart` - Don't auto-launch Vibe Kanban
- `--dry-run` - Preview without creating tasks
- `--verbose` - Debug output
- `--target DIR` - Install to specific directory

## Development Workflow

### For Story Development

```bash
# 1. Edit stories in bmad-templates/stories/
vim bmad-templates/stories/workflow-complet/1-1-0-brainstorm.md

# 2. Test in dev mode (fast iteration)
cd frontend && pnpm run dev
# Frontend: http://localhost:3001
# Stories hot-reload automatically

# 3. When ready, rebuild for production
./build-vibe-kanban.sh
```

### For Vibe Kanban Development

```bash
# Frontend dev (with hot reload)
cd frontend && pnpm run dev

# Backend dev (with auto-restart)
pnpm run backend:dev:watch

# Full dev stack
pnpm run dev
```

## Troubleshooting

### Stories Not Updating

**Problem:** Modified stories don't appear in build

**Solution:**
```bash
# Force rebuild
rm -rf frontend/dist
./build-vibe-kanban.sh
```

### Manifest Errors

**Problem:** TypeScript errors in `storyParser.ts`

**Cause:** Corrupt manifest from sync script

**Solution:**
```bash
# Clean and rebuild
rm frontend/src/services/storyParser.ts.bak 2>/dev/null
./build-vibe-kanban.sh
```

### Installer Too Large

**Problem:** Installer >100 MB

**Cause:** Multiple binaries embedded or unoptimized build

**Solution:**
```bash
# Rebuild with release optimization
cargo clean
./build-vibe-kanban.sh
./build-installer.sh
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable

      - name: Build Vibe Kanban
        run: ./build-vibe-kanban.sh

      - name: Build Installer
        run: ./build-installer.sh

      - name: Upload Release Asset
        uses: actions/upload-release-asset@v1
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ./dist/install-bmad-vibe-kanban.sh
          asset_name: install-bmad-vibe-kanban-macos.sh
          asset_content_type: application/x-sh
```

## Release Checklist

Before creating a release:

- [ ] All stories reviewed and tested
- [ ] Version bumped in `bmad-templates/VERSION`
- [ ] Changelog updated
- [ ] Build scripts tested
- [ ] Installer tested in clean environment
- [ ] Documentation updated

```bash
# Build release
./build-vibe-kanban.sh
./build-installer.sh

# Test installer
mkdir /tmp/release-test && cd /tmp/release-test
~/Dev/agents/vibe-kanban/dist/install-bmad-vibe-kanban.sh --skip-deps --no-autostart

# Verify
find . -name "*.md" | wc -l  # Should be 40
ls _bmad/bmm/workflows/      # Should show workflows

# Create git tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## Additional Resources

- **[TESTING-CHECKLIST.md](./TESTING-CHECKLIST.md)** - Complete validation guide
- **[FORK.md](./FORK.md)** - Fork relationship with upstream Vibe Kanban
- **[AGENTS.md](./AGENTS.md)** - Development guidelines
- **[README.md](./README.md)** - Project overview

## Support

For issues or questions:
- GitHub Issues: https://github.com/your-org/bmad-vibe-kanban/issues
- Documentation: See docs/ directory
