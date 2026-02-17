# Vibe Kanban - Documentation Index

> AI coding agent orchestration and task management platform (Deep Scan)

---

## Project Overview

| Attribute | Value |
|-----------|-------|
| **Type** | Polyglot monorepo (Rust + TypeScript), 6 application parts |
| **Primary Languages** | Rust nightly (backend), TypeScript 5.9 (frontend) |
| **Architecture** | Layered full-stack with Deployment Trait abstraction |
| **Distribution** | npm (`npx vibe-kanban`), 6-platform cross-compiled binaries |
| **Version** | 0.1.4 (permanent fork from BloopAI/vibe-kanban) |
| **Backend Framework** | Axum 0.8 + Tokio async runtime |
| **Frontend Framework** | React 18 + Vite 5 + TailwindCSS |
| **Local Database** | SQLite (44 migrations, 16 tables) |
| **Remote Database** | PostgreSQL (25+ tables) |

---

## Quick Reference by Part

### Part 1: Local Server (Rust Backend)

- **Type:** Backend application
- **Tech Stack:** Axum 0.8, Tokio, SQLx (SQLite), rust-embed
- **Entry Point:** `crates/server/src/main.rs`
- **Root:** `/crates/` (10 crates in workspace)
- **Endpoints:** 50+ REST + SSE + WebSocket

### Part 2: Frontend (React SPA)

- **Type:** Web application
- **Tech Stack:** React 18, Vite 5, TailwindCSS, Zustand, TanStack Query
- **Entry Point:** `frontend/src/main.tsx`
- **Root:** `/frontend/`
- **Components:** 220+ (Container/View pattern)

### Part 3: Remote Frontend

- **Type:** Web application
- **Tech Stack:** React 18, Vite 5, TailwindCSS
- **Entry Point:** `remote-frontend/src/main.tsx`
- **Root:** `/remote-frontend/`

### Part 4: Remote Server (Rust Backend)

- **Type:** Cloud backend
- **Tech Stack:** Axum 0.8, Tokio, SQLx (PostgreSQL), JWT auth
- **Entry Point:** `crates/remote/src/app.rs`
- **Root:** `crates/remote/`
- **Endpoints:** 60+ with Stripe billing, GitHub App integration

### Part 5: Shared Types

- **Type:** Library
- **Tech Stack:** TypeScript (ts-rs generated from Rust)
- **Entry Point:** `shared/types.ts`
- **Root:** `/shared/`

### Part 6: NPX CLI

- **Type:** CLI wrapper
- **Tech Stack:** Node.js
- **Entry Point:** `npx-cli/bin/cli.js`
- **Root:** `/npx-cli/`

---

## Generated Documentation (Deep Scan)

### Core Documentation

| Document | Lines | Description |
|----------|-------|-------------|
| [Project Overview](./project-overview.md) | 330 | Executive summary, capabilities, tech stack, key patterns |
| [Architecture](./architecture.md) | 1119 | System design, crate hierarchy, Deployment Trait, real-time comms, auth |
| [Source Tree Analysis](./source-tree-analysis.md) | 569 | Annotated directory tree for all 6 parts with integration diagrams |
| [Development Guide](./development-guide.md) | 936 | Prerequisites, setup, commands, build, testing, Docker, release pipeline |

### Integration & Communication

| Document | Lines | Description |
|----------|-------|-------------|
| [Integration Architecture](./integration-architecture.md) | 1329 | Inter-part communication, event system, external services, build-time integration |

### Technical Reference

| Document | Lines | Description |
|----------|-------|-------------|
| [API Contracts](./api-contracts.md) | 598 | 50+ local endpoints, 60+ remote endpoints, SSE/WebSocket, auth details |
| [Data Models](./data-models.md) | 650 | 16 SQLite tables, 25+ PostgreSQL tables, 44 migrations, schema evolution |
| [Component Inventory](./component-inventory.md) | 535 | 220+ React components, Container/View pattern, stores, contexts, API layer |

### Raw Scan Data

| Document | Description |
|----------|-------------|
| [Rust Backend Deep Scan](./rust-backend-deep-scan.json) | Structured JSON: routes, models, modules, auth, config, entry points |
| [Project Scan Report](../project-scan-report.json) | Workflow state: steps, findings, project types, outputs |

---

## Existing Documentation

### Project Root

| Document | Description |
|----------|-------------|
| [README.md](../../README.md) | Installation, overview, contributing |
| [AGENTS.md](../../AGENTS.md) | AI agent configuration guidelines |
| [CODE-OF-CONDUCT.md](../../CODE-OF-CONDUCT.md) | Community guidelines |

### Part-Specific Documentation

| Document | Description |
|----------|-------------|
| [crates/remote/README.md](../../crates/remote/README.md) | Remote deployment guide (Docker Compose, env vars) |
| [npx-cli/README.md](../../npx-cli/README.md) | CLI distribution and publishing details |
| [frontend/CLAUDE.md](../../frontend/CLAUDE.md) | Frontend styling rules, design system, component patterns |
| [.claude/CLAUDE.md](../../.claude/CLAUDE.md) | Project-level coding standards and conventions |

### Build & Verification Guides

| Document | Description |
|----------|-------------|
| [BUILD-GUIDE.md](./BUILD-GUIDE.md) | Build process reference |
| [TESTING-CHECKLIST.md](./TESTING-CHECKLIST.md) | Testing verification checklist |
| [CLAUDE-VERIFICATION-GUIDE.md](./CLAUDE-VERIFICATION-GUIDE.md) | AI agent verification procedures |

### User Documentation (Mintlify)

The `docs/docs-vibe-kanban/` folder contains the public documentation site:

- [Getting Started](./getting-started.mdx) - Installation and first-run guide
- [Supported Coding Agents](./supported-coding-agents.mdx) - Agent compatibility matrix
- [Troubleshooting](./troubleshooting.mdx) - Common issues and solutions
- **Agent Guides:** `agents/` - Claude Code, Gemini CLI, Codex, Cursor, Copilot, etc.
- **Core Features:** `core-features/` - Tasks, Workspaces, Code Review, Git Integration
- **Configuration:** `configuration-customisation/` - Settings, Keyboard Shortcuts, Tags
- **Cloud Features:** `cloud/` - Organizations, Issues, Billing, GitHub App
- **Workspaces:** `workspaces/` - Workspace lifecycle, sessions, execution processes
- **Settings:** `settings-beta/` - Beta features configuration
- **Integrations:** `integrations/` - External service integrations

---

## Key Architectural Patterns

| Pattern | Description | Location |
|---------|-------------|----------|
| **Deployment Trait** | Service locator abstraction enabling Local (SQLite) vs Cloud (PostgreSQL) | `crates/deployment/` |
| **Container/View** | Separation of data-fetching containers from stateless views | `frontend/src/components/ui-new/` |
| **Event Sourcing Lite** | SQLite hooks push JSON Patches to MsgStore, fanned out via SSE | `crates/utils/src/msg_store.rs` |
| **Executor Trait** | Common interface for 9 AI coding agents | `crates/executors/` |
| **Git Worktree Isolation** | Each workspace gets independent git worktrees | `crates/git/` |
| **ts-rs Type Generation** | Rust structs compile to TypeScript types | `shared/types.ts` |
| **rust-embed** | React SPA embedded into single Rust binary | `crates/server/` |
| **Origin Validation** | CSRF-like protection via VK_ALLOWED_ORIGINS | `crates/server/src/middleware/` |

---

## Getting Started

### For Development

```bash
# 1. Prerequisites
# Node.js >= 18, pnpm 10.13.1, Rust nightly-2025-12-04

# 2. Install dependencies
pnpm install

# 3. Generate TypeScript types from Rust
pnpm run generate-types

# 4. Start development servers (frontend + backend)
pnpm run dev

# 5. Open browser (ports shown in terminal)
```

See [Development Guide](./development-guide.md) for detailed setup, build, testing, and release instructions.

### For AI-Assisted Development

When using AI agents to work on this codebase:

1. **Start here:** Point to this index for project overview
2. **Architecture context:** Reference [Architecture](./architecture.md) for system design
3. **Frontend changes:** Reference [frontend/CLAUDE.md](../../frontend/CLAUDE.md) for styling rules and [Component Inventory](./component-inventory.md) for existing components
4. **Backend changes:** Reference [Architecture](./architecture.md) for crate hierarchy and patterns
5. **API changes:** Reference [API Contracts](./api-contracts.md) for endpoint documentation
6. **Database changes:** Reference [Data Models](./data-models.md) for schema details
7. **Type changes:** Run `pnpm run generate-types` after Rust struct modifications
8. **Integration work:** Reference [Integration Architecture](./integration-architecture.md) for cross-part communication

### Full Build

```bash
# Build complete application (frontend + backend → single binary)
./build-vibe-kanban.sh

# Or step by step:
pnpm run generate-types
cd frontend && pnpm run build && cd ..
cargo build --release --bin server
```

---

## External Service Integrations

| Service | Purpose | Configuration |
|---------|---------|---------------|
| **GitHub App** | Repo access, webhooks, PR management | OAuth + installation tokens |
| **Stripe** | Billing, subscriptions | Webhook + API keys |
| **PostHog** | Product analytics | `POSTHOG_API_KEY` |
| **Sentry** | Error tracking (frontend + backend) | `SENTRY_DSN` |
| **Cloudflare R2** | Binary distribution storage | AWS-compatible S3 API |
| **Electric SQL** | Real-time PostgreSQL sync to frontend | HTTP shape streams |

---

## Project Metadata

| Field | Value |
|-------|-------|
| **Version** | 0.1.4 |
| **Fork Origin** | BloopAI/vibe-kanban |
| **Repository** | fabthefabulousfab/bmad-vibe-kanban |
| **Documentation Generated** | 2026-02-17 |
| **Scan Level** | Deep (full source analysis with parallel agents) |
| **Workflow Version** | 1.2.0 |
| **Total Documentation** | 8 generated files, 6066 lines |

---

*Generated by BMAD Document Project Workflow v1.2.0 (Deep Scan)*
