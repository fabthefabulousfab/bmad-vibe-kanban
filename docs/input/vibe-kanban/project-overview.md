# BMAD Vibe Kanban - Project Overview

## Executive Summary

**BMAD Vibe Kanban** is a desktop-first task management and AI agent orchestration platform designed for software development teams practicing AI-assisted workflows. It is a **permanent fork of Vibe Kanban v0.1.4** that integrates the BMAD (Build, Manage, Analyze, Deploy) methodology for automated workflow and story generation.

### What It Is

A polyglot monorepo combining a Rust backend with a React TypeScript frontend, providing:
- Local-first task and project management with optional cloud sync
- Multi-repository workspace management with git worktree isolation
- AI coding agent orchestration supporting 9+ agents (Claude Code, Cursor, Gemini, etc.)
- Code review automation with PR management
- Real-time execution monitoring via SSE and WebSocket
- BMAD workflow templates for complete development lifecycles

### Who It's For

- Development teams practicing AI-assisted development
- Organizations requiring data sovereignty and privacy (local-first architecture)
- Teams working on multi-repository projects
- Developers using Claude Code, Cursor, or other AI coding assistants
- Product managers and technical leads implementing structured workflow methodologies

### Version Information

- **Current Version:** 0.1.4
- **Fork Point:** Vibe Kanban v0.1.4 (commit 41d51377, February 5, 2026)
- **Fork Status:** Permanently isolated from upstream for data sovereignty
- **License:** Apache 2.0

## Key Capabilities

### 1. Task Management
- Hierarchical project-task-workspace structure
- Task status tracking (Todo, InProgress, InReview, Done, Cancelled)
- Parent-child task relationships
- Tag-based organization
- Image attachments with content-addressed deduplication
- Scratch pad for draft notes and follow-ups

### 2. AI Agent Orchestration
- Support for 9 coding agents: ClaudeCode, Amp, Gemini, Codex, Opencode, CursorAgent, QwenCode, Copilot, Droid
- Configurable executor profiles with MCP (Model Context Protocol) support
- Tool call approval system for human-in-the-loop safety
- Session management with fork capability
- Real-time log streaming and diff visualization
- Automatic log normalization across different agent formats

### 3. Code Review Automation
- Multi-platform PR management (GitHub, Azure DevOps)
- PR status monitoring with 60s background polling
- Review request workflow with automated agent feedback
- Merge operations: direct merge, squash merge, rebase
- Conflict detection and resolution guidance

### 4. Multi-Repository Support
- Git worktree-based workspace isolation
- Parallel task execution on different worktrees
- Per-repository setup, cleanup, and dev server scripts
- Automatic repository discovery from filesystem
- Branch management with configurable target branches
- File search cache with git history-based ranking

### 5. BMAD Workflow System
- Pre-built workflow stories: `workflow-complet` (18 stories), `document-project` (10), `quick-flow` (4), `debug` (7)
- Wave-Epic-Story (WES) numbering system for traceability
- UI-based story import with workflow selection
- Executable workflow templates for AI agents
- Acceptance criteria and test specifications included

### 6. Real-Time Monitoring
- Server-Sent Events (SSE) for execution streams and event updates
- WebSocket for terminal PTY and scratch pad streaming
- JSON Patch-based event delivery via MsgStore
- Diff streaming with real-time statistics
- Console message and network request logging

## Tech Stack Summary

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Backend Language** | Rust 2021 | High-performance, memory-safe system operations |
| **Backend Framework** | Axum 0.8.4 | Async HTTP server with middleware |
| **Database (Local)** | SQLite + sqlx | Embedded database with compile-time query checking |
| **Database (Remote)** | PostgreSQL | Cloud server database |
| **ORM/Query** | sqlx | Type-safe SQL queries with macros |
| **Frontend Framework** | React 18.2 | UI component library |
| **Frontend Language** | TypeScript 5.9 | Type-safe JavaScript |
| **Build Tool** | Vite 5.0 | Fast frontend bundler |
| **State Management** | Zustand 4.5 + TanStack Query 5.85 | Client state + server state |
| **Styling** | Tailwind CSS 3.4 | Utility-first CSS framework |
| **Component Library** | Radix UI + shadcn/ui | Accessible headless components |
| **Git Operations** | libgit2 + git CLI | Version control integration |
| **Terminal** | xterm.js 5.5 | Browser-based terminal emulator |
| **Real-Time** | SSE + WebSocket | Bidirectional communication |
| **Type Sharing** | ts-rs | Rust to TypeScript type generation |
| **Analytics** | PostHog | Product analytics |
| **Monitoring** | Sentry | Error tracking |
| **Package Manager** | pnpm 10.13 | Efficient dependency management |

## Architecture Classification

**Polyglot Monorepo - 6 Parts:**

### 1. Local Server (Rust - `crates/server`, `crates/local-deployment`)
- Desktop application server
- SQLite database
- Origin-based CSRF protection
- Port auto-assignment with browser launch
- Serves frontend static files

### 2. Remote Server (Rust - `crates/remote`)
- Optional cloud sync server
- PostgreSQL database
- JWT authentication
- OAuth providers (GitHub, Google)
- Organization and billing management
- Excluded from main workspace build

### 3. Core Services (Rust - `crates/services`, `crates/deployment`)
- Business logic layer
- Container lifecycle management
- Workspace and worktree management
- Event streaming
- Configuration management
- File system operations
- Git host providers (GitHub, Azure DevOps)
- Migration between local and remote

### 4. Executors (Rust - `crates/executors`)
- Coding agent implementations
- MCP configuration per agent
- Log normalization
- Approval integration
- Action chaining (setup → agent → cleanup)

### 5. Foundation (Rust - `crates/db`, `crates/git`, `crates/utils`)
- Database models and migrations
- Git operations (worktree, merge, rebase, PR)
- Shared utilities (API types, diff, browser, shell, JWT)

### 6. Frontend (TypeScript - `frontend/`)
- React SPA with Vite
- TanStack Query for server state
- Zustand for client state
- Lexical rich text editor
- CodeMirror for code display
- Terminal emulator
- Diff visualization

## Repository Structure Overview

```
bmad-vibe-kanban/
├── crates/                      # Rust backend (local server)
│   ├── server/                  # HTTP server entry point
│   ├── db/                      # SQLite models and migrations
│   ├── services/                # Business logic layer
│   ├── executors/               # Coding agent implementations
│   ├── git/                     # Git operations
│   ├── utils/                   # Shared utilities
│   ├── deployment/              # Deployment trait abstraction
│   ├── local-deployment/        # Local implementation
│   ├── review/                  # Standalone PR review CLI
│   └── remote/                  # Remote cloud server (excluded)
├── frontend/                    # React TypeScript frontend
│   ├── src/
│   │   ├── api/                 # API client and types
│   │   ├── components/          # React components
│   │   ├── containers/          # Stateful containers
│   │   ├── views/               # Stateless view components
│   │   ├── ui-new/              # New design system components
│   │   ├── hooks/               # React hooks
│   │   ├── stores/              # Zustand stores
│   │   └── styles/              # CSS and Tailwind config
│   └── public/
│       └── stories/             # BMAD workflow stories (synced)
├── bmad-templates/              # BMAD sources for installer
│   ├── stories/                 # Workflow story templates (source)
│   ├── _bmad/                   # BMAD framework sources
│   ├── scripts/                 # BMAD tooling scripts
│   └── docs/                    # BMAD documentation
├── _bmad/                       # BMAD framework (active root)
├── .claude/                     # Claude Code configuration
├── scripts/                     # Build and sync scripts
│   ├── sync-stories.sh          # Sync templates → frontend
│   ├── build-vibe-kanban.sh     # Build complete app
│   └── build-installer.sh       # Create self-extracting installer
├── tools/                       # Development tools
│   └── workflow-sync/           # LLM-based workflow analyzer
├── docs/                        # Documentation
│   ├── docs-vibe-kanban/        # Vibe Kanban docs
│   ├── docs-bmad-template/      # BMAD methodology docs
│   └── docs-integration/        # Integration and fork docs
├── dist/                        # Build artifacts (gitignored)
└── _bmad-output/                # Generated content (gitignored)
```

## Key Architectural Patterns

### Deployment Trait Pattern
Abstract trait allowing `LocalDeployment` and future cloud implementations to share the same service interfaces.

### Event Sourcing Lite
SQLite hooks on INSERT/UPDATE → after_connect callback → MsgStore patches → SSE/WebSocket delivery for real-time UI updates.

### Worktree Isolation
Each workspace gets isolated git worktrees per repository, enabling parallel task execution without conflicts.

### Action Chaining
`ExecutorAction` with `next_action` field sequences operations: setup script → coding agent → cleanup script.

### Type Safety End-to-End
- Rust types with ts-rs → TypeScript types
- sqlx compile-time query checking
- Zod validation on frontend

### Origin Validation CSRF
Local server validates request origins against `VK_ALLOWED_ORIGINS` environment variable instead of traditional CSRF tokens.

## Documentation Links

### Architecture and Design
- [architecture.md](./architecture.md) - Detailed system architecture
- [integration-architecture.md](../docs-integration/integration-architecture.md) - BMAD integration design
- [api-contracts.md](./api-contracts.md) - API endpoint reference
- [rust-backend-deep-scan.json](./rust-backend-deep-scan.json) - Complete backend scan

### Build and Development
- [BUILD-GUIDE.md](./BUILD-GUIDE.md) - Complete build documentation
- [development-guide.md](./development-guide.md) - Developer setup guide
- [TESTING-CHECKLIST.md](./TESTING-CHECKLIST.md) - 6-phase testing guide
- [AGENTS.md](./AGENTS.md) - Development guidelines

### Fork Information
- [FORK.md](../docs-integration/FORK.md) - Fork relationship and strategy
- [MODIFICATION_FORK.md](./fork-history/MODIFICATION_FORK.md) - Detailed modifications
- [FORK-RESTORATION.md](../../FORK-RESTORATION.md) - Restoration to v0.1.4

### BMAD Methodology
- [00-BMAD-TEA-MASTER-GUIDE.md](../docs-bmad-template/methodology/00-BMAD-TEA-MASTER-GUIDE.md) - Methodology overview
- [01-WORKFLOW-PHASES-COMPLETE.md](../docs-bmad-template/methodology/01-WORKFLOW-PHASES-COMPLETE.md) - Story philosophy
- [03-GUIDE-CHOIX-WORKFLOW.md](../docs-bmad-template/methodology/03-GUIDE-CHOIX-WORKFLOW.md) - Workflow selection guide

### User Guides
- [README.md](../../README.md) - Quick start and installation
- [DOCUMENTATION.md](../../DOCUMENTATION.md) - Complete documentation index

## Data Flow Summary

### Task Creation Flow
1. User creates task via UI → POST `/api/tasks`
2. Backend inserts into SQLite with event hook
3. SQLite trigger → MsgStore patch generation
4. Patch streamed to clients via `/api/events` SSE
5. Frontend applies JSON Patch to local state

### Workspace Execution Flow
1. User starts task attempt → POST `/api/task-attempts/:id/start`
2. Backend creates worktrees for all project repos
3. Runs setup scripts → creates session → spawns coding agent
4. Agent execution → real-time logs via `/api/execution-processes/:id/stream` SSE
5. Git state tracked per-repo in `execution_process_repo_states`
6. Completion → cleanup script → workspace archived or deleted

### PR Creation Flow
1. User clicks "Create PR" → POST `/api/task-attempts/:id/create-pr`
2. Backend detects git host from remote URL
3. GitHostProvider (GitHub/AzureDevOps) creates PR via API
4. PR metadata stored in `merges` table
5. PrMonitorService polls status every 60s
6. Status updates streamed to UI via events

## Security Model

### Local Server
- **CSRF Protection:** Origin header validation via `VK_ALLOWED_ORIGINS`
- **No Authentication:** Runs on localhost with origin checks
- **OAuth Delegation:** Tokens managed via remote server handoff
- **File System Access:** Limited to discovered repositories

### Remote Server
- **Authentication:** JWT session tokens
- **Authorization:** Organization membership checks
- **OAuth Providers:** GitHub and Google
- **CORS:** Mirror request with credentials

### Executor Approvals
- **Approval System:** Tool calls require user approval before execution
- **Storage:** In-memory DashMap with pending/completed states
- **Flow:** Agent → approval request → UI prompt → oneshot channel → agent proceeds

## Migration and Versioning

### Database Migrations
- **Local:** 44 SQLite migrations from 2025-06-17 to 2026-02-03
- **Remote:** PostgreSQL migrations managed separately
- **Migration State:** Tracked in `migration_state` table for local-to-remote sync

### Config Versioning
- **Current:** v8 with automatic migration from older versions
- **Location:** `asset_dir/config.json`
- **Migration:** Automatic on load with backwards compatibility

### Type Safety
- **ts-rs:** Automatic TypeScript type generation from Rust
- **Check Scripts:** `pnpm run generate-types:check` validates sync
- **CI Integration:** Type generation failures block builds

## Performance Characteristics

### File Search
- **Cache:** In-memory file search cache with git history ranking
- **Warm-up:** Background cache population on server start
- **Ranking:** Recent files ranked higher based on git log

### Database
- **Local:** SQLite with WAL mode for concurrent reads
- **Indexes:** Optimized queries with compile-time checking
- **Event Hooks:** Minimal overhead for real-time updates

### Real-Time Communication
- **SSE:** Server-Sent Events for one-way server-to-client streams
- **WebSocket:** Bidirectional for terminal and scratch pad
- **Batch Updates:** JSON Patch arrays reduce message overhead

---

*Generated by BMAD Document Project Workflow v1.2.0 (Deep Scan)*
