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

## BMAD Story Philosophy

BMAD stories are designed as **executable workflows** for AI-assisted development. Unlike traditional user stories, they:

- **Guide AI agents** through complete development workflows (from ideation to deployment)
- **Organize by phases** using Wave-Epic-Story (WES) numbering (e.g., 1-2-3 = Wave 1, Epic 2, Story 3)
- **Provide context** with acceptance criteria, test plans, and traceability
- **Enable automation** through structured markdown that AI agents can parse and execute

### Story Workflows

| Workflow | Stories | Purpose |
|----------|---------|---------|
| **workflow-complet** | 18 | Complete product development (ideation → deployment) |
| **document-project** | 10 | Documentation-first approach for existing codebases |
| **quick-flow** | 4 | Fast feature development workflow |
| **debug** | 7 | Bug investigation and resolution workflow |

Each story includes:
- Clear objectives and context
- Acceptance criteria
- Test specifications
- Traceability to epics and waves
- AI agent instructions

For complete philosophy and specifications, see:
- [bmad-templates/docs/01-WORKFLOW-PHASES-COMPLETE.md](./bmad-templates/docs/01-WORKFLOW-PHASES-COMPLETE.md) - Complete workflow phases
- [bmad-templates/docs/03-GUIDE-CHOIX-WORKFLOW.md](./bmad-templates/docs/03-GUIDE-CHOIX-WORKFLOW.md) - Workflow selection guide

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

📚 **[Complete Documentation Index](./DOCUMENTATION.md)** - Browse all documentation organized by topic and audience

### Quick Links

**Build & Deploy:**
- [BUILD-GUIDE.md](./docs/BUILD-GUIDE.md) - Complete build documentation
- [TESTING-CHECKLIST.md](./docs/TESTING-CHECKLIST.md) - Testing guide (6 phases)

**Architecture:**
- [architecture.md](./docs/architecture.md) - System architecture
- [integration-architecture.md](./docs/integration-architecture.md) - BMAD integration

**Fork Information:**
- [FORK.md](./docs/FORK.md) - Fork relationship and strategy
- [MODIFICATION_FORK.md](./docs/fork-history/MODIFICATION_FORK.md) - Detailed modifications

**BMAD Philosophy:**
- [BMAD Master Guide](./bmad-templates/docs/00-BMAD-TEA-MASTER-GUIDE.md) - Methodology overview
- [Complete Workflow Phases](./bmad-templates/docs/01-WORKFLOW-PHASES-COMPLETE.md) - Story philosophy
- [Workflow Selection](./bmad-templates/docs/03-GUIDE-CHOIX-WORKFLOW.md) - Choose the right workflow

**Development:**
- [AGENTS.md](./docs/AGENTS.md) - Development guidelines
- [development-guide.md](./docs/development-guide.md) - Developer setup
- [CLAUDE.md](./.claude/CLAUDE.md) - Claude Code instructions

For the complete documentation structure, see [DOCUMENTATION.md](./DOCUMENTATION.md).

## Fork Information

**Upstream:** [github.com/BloopAI/vibe-kanban](https://github.com/BloopAI/vibe-kanban)
**Fork Point:** v0.1.4
**License:** Apache 2.0

For detailed fork information and modifications, see:
- [FORK.md](./FORK.md) - Fork relationship and strategy
- [docs/fork-history/MODIFICATION_FORK.md](./docs/fork-history/MODIFICATION_FORK.md) - Detailed modifications

## License

Apache License 2.0

This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE) file for details.
