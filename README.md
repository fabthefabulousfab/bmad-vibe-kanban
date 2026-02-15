# BMAD Vibe Kanban

**Build, Manage, Analyze, Deploy workflows with Vibe Kanban**

This project is a **fork of Vibe Kanban 0.1.4** ([upstream](https://github.com/BloopAI/vibe-kanban)) with integrated BMAD methodology for automated workflow and story generation.

## What's New in This Fork

- ✅ **BMAD Story Templates** - Pre-built workflow stories (workflow-complet, quick-flow, document-project, debug)
- ✅ **Self-Extracting Installer** - Portable installer with embedded Vibe Kanban binary
- ✅ **Automated Story Import** - UI-based import with workflow selection
- ✅ **BMAD Methodology** - Complete Build-Manage-Analyze-Deploy framework
- ✅ **Claude Code Integration** - Pre-configured workflows for Claude
- ✅ **Unified Repository** - BMAD templates + Vibe Kanban in one place

## Quick Start

### For Users (Installing BMAD in a Project)

```bash
# Download and run the installer
curl -O https://github.com/your-org/bmad-vibe-kanban/releases/latest/download/install-bmad-vibe-kanban.sh
chmod +x install-bmad-vibe-kanban.sh
./install-bmad-vibe-kanban.sh
```

The installer:
1. Extracts BMAD framework (stories, scripts, _bmad)
2. Installs dependencies
3. Starts Vibe Kanban
4. Opens browser to import workflows

### For Developers (Building This Repository)

```bash
# Clone the repository
git clone https://github.com/your-org/bmad-vibe-kanban.git
cd bmad-vibe-kanban

# Install dependencies
pnpm install

# Build Vibe Kanban with BMAD stories
./build-vibe-kanban.sh

# Build self-extracting installer
./build-installer.sh
```

**📖 Complete build documentation:** See [BUILD-GUIDE.md](./BUILD-GUIDE.md)

## Project Structure

```
bmad-vibe-kanban/
├── frontend/              # Vibe Kanban React app (fork)
├── crates/                # Vibe Kanban Rust backend (fork)
├── npx-cli/               # Binary packaging (fork)
├── _bmad/                 # BMAD methodology (root for active use)
├── .claude/               # Claude Code configuration (root for active use)
├── bmad-templates/        # BMAD sources for installer
│   ├── stories/           # Workflow story templates
│   ├── _bmad/             # BMAD sources (copied to root)
│   ├── scripts/           # BMAD tooling scripts
│   ├── templates/         # Project templates
│   ├── .claude/           # Claude config sources
│   └── docs/              # BMAD documentation
├── scripts/               # Root build scripts
│   ├── sync-stories.sh    # Sync templates → frontend
│   ├── build-vibe-kanban.sh
│   └── build-installer.sh
├── dist/                  # Build artifacts (gitignored)
├── _bmad-output/          # BMAD generated content (gitignored)
└── docs/                  # Vibe Kanban documentation
```

## Development

### Story Modification Workflow

```bash
# 1. Edit story templates in bmad-templates/stories/
vim bmad-templates/stories/workflow-complet/1-1-0-brainstorm.md

# 2. Rebuild (auto-syncs stories to frontend)
./build-vibe-kanban.sh

# 3. Test in dev mode
cd frontend && pnpm run dev
```

**Key Concept:** Stories are sourced from `bmad-templates/stories/` and automatically synced to `frontend/public/stories/` during build. The build process also updates manifests in `storyParser.ts`.

### Complete Build Workflow

```bash
# 1. Edit stories (if needed)
vim bmad-templates/stories/workflow-complet/1-1-0-brainstorm.md

# 2. Build Vibe Kanban (syncs stories + builds frontend + compiles backend)
./build-vibe-kanban.sh

# 3. Test the binary
./target/release/server
# Opens browser to http://127.0.0.1:{port}

# 4. Build installer (when ready for distribution)
./build-installer.sh

# 5. Test installer
mkdir /tmp/test && cd /tmp/test
~/path/to/vibe-kanban/dist/install-bmad-vibe-kanban.sh --help
```

**Important:** The installer will always use the **latest stories from bmad-templates/** because `./build-vibe-kanban.sh` syncs them before compiling the backend.

### Testing

```bash
# Quick validation
./scripts/quick-check.sh

# Complete testing guide
# See TESTING-CHECKLIST.md
```

## Documentation

### Repository Documentation

- **[FORK.md](./FORK.md)** - Fork relationship with upstream Vibe Kanban, syncing strategy, version numbering
- **[TESTING-CHECKLIST.md](./TESTING-CHECKLIST.md)** - Complete testing guide for validating builds (6 phases)
- **[CLAUDE-VERIFICATION-GUIDE.md](./CLAUDE-VERIFICATION-GUIDE.md)** - Quick reference for Claude Code verification sessions
- **[README-VK-ORIGINAL.md](./README-VK-ORIGINAL.md)** - Original Vibe Kanban documentation and features
- **[AGENTS.md](./AGENTS.md)** - Development guidelines, build commands, project structure
- **[CODE-OF-CONDUCT.md](./CODE-OF-CONDUCT.md)** - Community guidelines (inherited from upstream)

### Additional Documentation

- **[docs/fork-history/](./docs/fork-history/)** - Historical fork modifications and changes
- **[bmad-templates/docs/](./bmad-templates/docs/)** - BMAD methodology documentation
- **[.claude/CLAUDE.md](./.claude/CLAUDE.md)** - Claude Code project instructions

## Fork Information

**Upstream:** [github.com/BloopAI/vibe-kanban](https://github.com/BloopAI/vibe-kanban)
**Fork Point:** v0.1.4
**License:** MIT

For detailed fork information, see [FORK.md](./FORK.md).

## License

MIT License (same as Vibe Kanban upstream)
