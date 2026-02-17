# Source Tree Analysis

> Annotated directory structure of the Vibe Kanban codebase

## Complete Project Tree

```
vibe-kanban/
├── .cargo/                      # Cargo configuration
├── .github/                     # GitHub Actions workflows
│   └── workflows/              # CI/CD pipeline definitions
├── assets/                      # Packaged production assets
├── crates/                      # 🦀 Rust workspace (backend)
│   ├── db/                     # Database layer
│   │   ├── migrations/         # 📦 SQLx migrations (65+ files)
│   │   └── src/               # SQLx models, queries
│   ├── deployment/            # Deployment trait abstractions
│   ├── executors/             # 🤖 AI agent implementations
│   │   └── src/executors/     # Per-agent executor code
│   │       ├── claude_code/   # Claude Code executor
│   │       ├── gemini_cli/    # Gemini CLI executor
│   │       ├── codex/         # OpenAI Codex executor
│   │       └── ...            # Other agents
│   ├── local-deployment/      # Local SQLite deployment
│   ├── remote/                # Remote PostgreSQL deployment
│   │   ├── migrations/        # PostgreSQL migrations
│   │   └── src/              # Remote-specific logic
│   ├── review/                # Code review functionality
│   ├── server/                # 🚀 Main application server
│   │   └── src/
│   │       ├── bin/          # Binary entry points
│   │       │   ├── server.rs # Main server binary
│   │       │   └── generate_types.rs # ts-rs type generator
│   │       ├── routes/       # 🌐 API route handlers (21 files)
│   │       ├── middleware/   # Axum middleware
│   │       ├── mcp/          # MCP server integration
│   │       ├── main.rs       # Entry point
│   │       └── error.rs      # Error handling
│   ├── services/              # 📋 Business logic services
│   └── utils/                 # Shared utilities
├── dev_assets_seed/            # Seed data for development
├── docs/                       # 📚 Mintlify documentation site
│   ├── agents/                # Per-agent documentation
│   ├── core-features/         # Feature guides
│   ├── configuration-customisation/
│   └── images/                # Documentation screenshots
├── frontend/                   # ⚛️ React SPA
│   ├── public/                # Static assets
│   └── src/
│       ├── components/        # 🧩 React components (29 folders)
│       │   ├── dialogs/       # Modal dialogs
│       │   ├── kanban/        # Kanban board components
│       │   ├── layout/        # Layout components
│       │   └── ...
│       ├── contexts/          # React context providers (20 files)
│       ├── hooks/             # Custom hooks (85+ hooks)
│       ├── stores/            # Zustand stores
│       ├── pages/             # Route pages
│       ├── lib/               # Utilities and helpers
│       ├── i18n/              # Internationalization
│       ├── keyboard/          # Keyboard shortcut handling
│       ├── styles/            # CSS and Tailwind config
│       ├── types/             # TypeScript type definitions
│       ├── utils/             # Frontend utilities
│       ├── App.tsx            # Root component
│       └── main.tsx           # Entry point
├── npx-cli/                    # 📦 npm package wrapper
│   ├── bin/                   # CLI entry point
│   └── dist/                  # Bundled binaries
├── remote-frontend/            # Remote deployment UI
├── scripts/                    # 🛠️ Development scripts
│   ├── setup-dev-environment.js
│   └── prepare-db.js
├── shared/                     # 🔗 Shared TypeScript types
│   ├── types.ts               # Generated from Rust via ts-rs
│   └── schemas/               # JSON schemas for agents
├── Cargo.toml                  # Rust workspace manifest
├── package.json                # Node.js root manifest
├── pnpm-workspace.yaml         # pnpm workspace config
└── README.md                   # Project documentation
```

## Critical Directories

### Backend (Rust)

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `crates/server/src/routes/` | API endpoints | 21 route handler files |
| `crates/server/src/bin/` | Entry points | `server.rs`, `generate_types.rs` |
| `crates/executors/src/executors/` | Agent implementations | One folder per AI agent |
| `crates/db/migrations/` | Database schema | 65+ migration files |
| `crates/db/src/` | Data models | SQLx queries and structs |
| `crates/services/src/` | Business logic | Service layer |

### Frontend (React)

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `frontend/src/components/` | UI components | 29 component directories |
| `frontend/src/hooks/` | Custom React hooks | 85+ hook files |
| `frontend/src/contexts/` | React contexts | 20 context providers |
| `frontend/src/stores/` | Zustand stores | Global state management |
| `frontend/src/pages/` | Route pages | Page components |

## Entry Points

| Part | Entry Point | Description |
|------|-------------|-------------|
| **Backend** | `crates/server/src/main.rs` | Axum server initialization |
| **Frontend** | `frontend/src/main.tsx` | React app mount |
| **CLI** | `npx-cli/bin/cli.js` | npm distribution entry |
| **Type Gen** | `crates/server/src/bin/generate_types.rs` | ts-rs type generation |

## Integration Paths

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend                              │
│  frontend/src/ ──────────────────────────────────────────┐  │
│       │                                                   │  │
│       │ imports                                           │  │
│       ▼                                                   │  │
│  shared/types.ts ◄──────── ts-rs generates ──────────────┤  │
│       │                         ▲                         │  │
│       │                         │                         │  │
│       │ HTTP/WS                 │                         │  │
│       ▼                         │                         │  │
├─────────────────────────────────│─────────────────────────┤  │
│                        Backend  │                         │  │
│  crates/server/src/routes/ ─────┘                         │  │
│       │                                                   │  │
│       │ calls                                             │  │
│       ▼                                                   │  │
│  crates/services/ ──► crates/db/ ──► SQLite              │  │
│       │                                                   │  │
│       │ spawns                                            │  │
│       ▼                                                   │  │
│  crates/executors/ ──► AI Agents (Claude, Gemini, etc.)  │  │
└─────────────────────────────────────────────────────────────┘
```

## File Count Summary

| Area | Files | Lines (approx) |
|------|-------|----------------|
| Rust crates | ~150 | 25,000+ |
| Frontend src | ~400 | 40,000+ |
| Migrations | 65+ | 2,000+ |
| Documentation | 30+ | 5,000+ |

---

*Generated by BMAD Document Project Workflow v1.2.0*
