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

# Build everything
./scripts/build-vibe-kanban.sh   # Build Vibe Kanban binary
./scripts/build-installer.sh      # Build self-extracting installer
```

## Project Structure

```
bmad-vibe-kanban/
├── frontend/              # Vibe Kanban React app (fork)
├── crates/                # Vibe Kanban Rust backend (fork)
├── npx-cli/               # Binary packaging (fork)
├── bmad-templates/        # BMAD framework addition
│   ├── stories/           # Workflow story templates
│   ├── _bmad/             # BMAD methodology docs
│   ├── scripts/           # BMAD tooling scripts
│   ├── templates/         # Project templates
│   └── .claude/           # Claude Code configuration
├── scripts/               # Root build scripts
│   ├── sync-stories.sh    # Sync templates → frontend
│   ├── build-vibe-kanban.sh
│   └── build-installer.sh
├── dist/                  # Build artifacts (gitignored)
└── docs/                  # Documentation
```

## Development

### Story Modification Workflow

```bash
# 1. Edit story templates
vim bmad-templates/stories/workflow-complet/1-1-0-brainstorm.md

# 2. Build (auto-syncs stories)
./scripts/build-vibe-kanban.sh

# 3. Test in dev mode
cd frontend && pnpm run dev
```

### Testing

```bash
# Run post-migration tests
cd test-tools
bats post-migration/*.bats
```

## Fork Information

**Upstream:** [github.com/BloopAI/vibe-kanban](https://github.com/BloopAI/vibe-kanban)
**Fork Point:** v0.1.4
**License:** MIT

See [README-VK-ORIGINAL.md](./README-VK-ORIGINAL.md) for original Vibe Kanban documentation.

## License

MIT License (same as Vibe Kanban upstream)
