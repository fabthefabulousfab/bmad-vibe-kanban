# Source Tree Analysis (Deep Scan)

> Annotated directory structure of the bmad-vibe-kanban monorepo
> Scan level: Deep | Generated: 2026-02-17

---

## Repository Root

```
bmad-vibe-kanban/
├── .cargo/                          # Cargo build configuration (linker flags for macOS)
├── .github/                         # CI/CD and GitHub configuration
│   ├── actions/setup-node/          # Reusable Node.js setup action
│   └── workflows/
│       ├── test.yml                 # PR checks: lint, format, type-check, cargo test/clippy
│       ├── pre-release.yml          # 6-platform build matrix, Apple signing, R2 upload
│       └── publish.yml              # npm publish with OIDC trusted publishing
├── .playwright-mcp/                 # Playwright MCP server configuration
├── _bmad/                           # BMAD methodology framework (excluded from app)
├── assets/                          # Production-embedded assets
│   ├── scripts/                     # Shell scripts bundled into binary
│   └── sounds/                      # Notification sound files
├── bmad-templates/                  # BMAD story/workflow templates
├── crates/                          # [PART: server] Rust workspace - 10 crates
│   ├── db/                          # Database layer (SQLite via SQLx)
│   ├── deployment/                  # Deployment trait abstraction
│   ├── executors/                   # AI agent executor implementations
│   ├── git/                         # Git operations (libgit2 via git2-rs)
│   ├── local-deployment/            # Local desktop deployment (SQLite)
│   ├── remote/                      # [PART: remote] Cloud deployment (PostgreSQL)
│   ├── review/                      # Standalone PR review CLI
│   ├── server/                      # Main Axum HTTP server
│   ├── services/                    # Business logic layer (27 service modules)
│   └── utils/                       # Shared utilities + ts-rs type bindings
├── dev_assets_seed/                 # Development seed data
├── docs/                            # Documentation root
│   ├── docs-bmad-template/          # BMAD template documentation
│   ├── docs-integration/            # Build/integration documentation
│   └── docs-vibe-kanban/            # Generated project documentation (this folder)
├── frontend/                        # [PART: frontend] React SPA
├── npx-cli/                         # [PART: npx-cli] npm distribution wrapper
├── remote-frontend/                 # [PART: remote-frontend] SaaS portal SPA
├── shared/                          # [PART: shared] Generated TypeScript types
├── Cargo.toml                       # Rust workspace manifest (nightly-2025-12-04)
├── Dockerfile                       # Multi-stage build (Node 24 + Rust -> Alpine)
├── package.json                     # Root Node.js manifest (dev scripts, concurrently)
├── pnpm-workspace.yaml              # pnpm workspace: frontend, remote-frontend
├── pnpm-lock.yaml                   # pnpm lockfile
├── rust-toolchain.toml              # Rust nightly channel pinning
├── rustfmt.toml                     # Rust formatting config
├── build-installer.sh               # macOS installer build script
├── build-vibe-kanban.sh             # Full build script (types + frontend + cargo)
├── local-build.sh                   # Local development build
├── quick-check.sh                   # Quick lint/format/type-check
└── README.md                        # Project overview and setup guide
```

---

## Part 1: Rust Backend (`crates/`)

The Rust workspace contains 10 crates with a clean dependency hierarchy.
Entry point: `crates/server/src/main.rs`

```
crates/
├── server/                          # ENTRY POINT - Main Axum HTTP server
│   └── src/
│       ├── main.rs                  # 15-step startup sequence
│       ├── error.rs                 # AppError with HTTP status mapping
│       ├── bin/
│       │   ├── server.rs            # Binary entry point (delegates to main.rs)
│       │   └── generate_types.rs    # ts-rs TypeScript type generator
│       ├── routes/                  # 50+ API endpoint handlers
│       │   ├── projects.rs          # CRUD + auto-setup, repo management
│       │   ├── tasks.rs             # Task CRUD + relationship queries
│       │   ├── task_attempts.rs     # Workspace lifecycle (start/merge/archive/PR)
│       │   ├── sessions.rs          # Session management + forking
│       │   ├── execution_processes.rs # Agent process lifecycle + SSE streams
│       │   ├── containers.rs        # Agent container start/stop/message
│       │   ├── events.rs            # SSE event stream + WebSocket scratch
│       │   ├── config.rs            # App configuration CRUD
│       │   ├── filesystem.rs        # File browsing, reading, writing
│       │   ├── search.rs            # Code search integration
│       │   ├── tags.rs              # Tag management
│       │   ├── scratch.rs           # Scratch pad persistence
│       │   ├── repos.rs             # Repository discovery + status
│       │   ├── oauth.rs             # OAuth handoff to remote server
│       │   ├── approvals.rs         # Tool call approval queue
│       │   ├── images.rs            # Image upload/retrieval
│       │   ├── health.rs            # Health check endpoint
│       │   ├── terminal.rs          # PTY WebSocket terminal
│       │   ├── migration.rs         # Data migration endpoints
│       │   └── pull_requests.rs     # PR monitoring integration
│       ├── middleware/              # Axum middleware stack
│       │   ├── origin.rs            # CSRF-like origin validation
│       │   └── project.rs           # Project/task/workspace loaders
│       └── mcp/                     # MCP (Model Context Protocol) server
│           └── mod.rs               # rmcp-based MCP tool exposure
│
├── db/                              # Database layer
│   ├── src/
│   │   ├── lib.rs                   # Connection pool, real-time hooks
│   │   └── models/                  # 16 SQLite model structs
│   │       ├── project.rs           # Project + ProjectRepo
│   │       ├── task.rs              # Task model
│   │       ├── workspace.rs         # Workspace + WorkspaceRepo
│   │       ├── session.rs           # Session model
│   │       ├── execution_process.rs # Agent execution tracking
│   │       ├── execution_process_logs.rs
│   │       ├── coding_agent_turns.rs
│   │       ├── image.rs             # Image + TaskImage
│   │       ├── merge.rs             # Merge records
│   │       ├── tag.rs               # Tagging system
│   │       └── scratch.rs           # Scratch pad storage
│   ├── migrations/                  # 44 SQLx migrations (2025-06 to 2026-02)
│   │   ├── 20250617_create_projects.sql
│   │   ├── ...
│   │   ├── 20251218_rename_task_attempts_to_workspaces.sql  # Major refactor
│   │   ├── 20251218_add_project_repositories.sql            # Multi-repo support
│   │   └── 20260203_*.sql           # Latest migrations
│   └── .sqlx/                       # SQLx offline query verification cache
│
├── services/                        # Business logic center
│   └── src/
│       ├── lib.rs                   # Service container (ServiceState)
│       └── services/                # 27 service modules
│           ├── container_service.rs # Agent container lifecycle
│           ├── workspace_service.rs # Workspace/worktree management
│           ├── session_service.rs   # Session + agent spawning
│           ├── event_service.rs     # Real-time event pub/sub
│           ├── diff_service.rs      # Git diff computation
│           ├── pr_monitor_service.rs # Pull request status tracking
│           ├── merge_service.rs     # Branch merge operations
│           ├── search_service.rs    # Code search (ripgrep)
│           ├── cache_service.rs     # In-memory cache warming
│           ├── executor_profile_service.rs # Agent profiles
│           ├── mcp_service.rs       # MCP tool registration
│           └── ...                  # 16 more service modules
│
├── executors/                       # AI agent implementations
│   └── src/
│       ├── lib.rs                   # Executor trait definition
│       ├── executors/               # 9 concrete executor implementations
│       │   ├── claude_code.rs       # Claude Code CLI integration
│       │   ├── amp.rs               # Amplify executor
│       │   ├── gemini_cli.rs        # Gemini CLI executor
│       │   ├── codex.rs             # OpenAI Codex executor
│       │   ├── cursor_agent.rs      # Cursor agent executor
│       │   ├── opencode.rs          # OpenCode executor
│       │   ├── qwen_code.rs         # Qwen Code executor
│       │   ├── copilot.rs           # GitHub Copilot executor
│       │   └── droid.rs             # Droid executor
│       ├── actions/                 # Shared executor actions
│       │   ├── git_commit.rs        # Auto-commit orchestration
│       │   └── save_chat.rs         # Conversation persistence
│       └── logs/                    # Log parsing and streaming
│           ├── parser.rs            # JSONL log file parser
│           └── streaming.rs         # Real-time log SSE delivery
│
├── git/                             # Git operations (1953 lines in GitService)
│   └── src/
│       ├── lib.rs                   # GitService: clone, worktree, branch, diff, merge
│       ├── auth.rs                  # Git credential management
│       └── blame.rs                 # Git blame support
│
├── deployment/                      # Deployment trait abstraction
│   └── src/
│       └── lib.rs                   # Deployment trait (service locator pattern)
│
├── local-deployment/                # Desktop deployment implementation
│   └── src/
│       └── lib.rs                   # LocalDeployment: SQLite + local filesystem
│
├── remote/                          # [SEPARATE PART] Cloud backend
│   ├── src/
│   │   ├── app.rs                   # Axum app builder (PostgreSQL)
│   │   ├── bin/
│   │   │   ├── remote.rs            # Remote server binary
│   │   │   └── migrate.rs           # Migration runner
│   │   ├── auth/                    # JWT + OAuth authentication
│   │   │   ├── jwt.rs               # JWT token issuance/verification
│   │   │   ├── oauth.rs             # GitHub/Google OAuth PKCE
│   │   │   └── encryption.rs        # AES-256-GCM token encryption
│   │   ├── routes/                  # 60+ API routes
│   │   │   ├── issues.rs            # Issue management
│   │   │   ├── organizations.rs     # Multi-tenant org management
│   │   │   ├── pull_requests.rs     # PR review pipeline
│   │   │   ├── billing.rs           # Stripe billing integration
│   │   │   ├── repos.rs             # Repository management
│   │   │   ├── workspaces.rs        # Remote workspace tracking
│   │   │   └── ...                  # 9 more route modules
│   │   ├── db/                      # 25+ PostgreSQL models
│   │   ├── github_app/              # GitHub App webhook handlers
│   │   └── middleware/              # JWT auth + org access control
│   ├── migrations/                  # PostgreSQL migrations
│   └── scripts/                     # Deployment scripts
│
├── review/                          # Standalone review CLI
│   └── src/
│       └── main.rs                  # PR review binary entry point
│
└── utils/                           # Shared utilities
    ├── src/
    │   ├── lib.rs                   # Common types, helpers
    │   └── api/                     # API response types
    └── bindings/                    # ts-rs generated TypeScript bindings
```

### Key Architectural Patterns in Rust Backend

| Pattern | Location | Description |
|---------|----------|-------------|
| **Deployment Trait** | `crates/deployment/` | Service locator abstraction enabling local vs cloud |
| **Service Layer** | `crates/services/` | All business logic isolated from HTTP handlers |
| **Event Sourcing Lite** | `crates/db/src/lib.rs` | SQLite hooks push JSON Patches to MsgStore |
| **Worktree Isolation** | `crates/git/src/lib.rs` | Each workspace gets independent git worktrees |
| **Executor Trait** | `crates/executors/src/lib.rs` | Common interface for 9 different AI agents |

---

## Part 2: React Frontend (`frontend/`)

Entry point: `frontend/src/main.tsx`
Build: Vite 5 with React Compiler (babel-plugin-react-compiler)

```
frontend/
├── public/                          # Static assets served directly
│   ├── agents/                      # Agent logos and icons
│   ├── guide-images/                # Onboarding guide images
│   ├── ide/                         # IDE integration assets
│   ├── mcp/                         # MCP configuration templates
│   └── stories/                     # Story template assets
├── src/
│   ├── main.tsx                     # ENTRY POINT - React root mount
│   ├── App.tsx                      # Root component with providers
│   ├── components/                  # 90+ React components
│   │   ├── NormalizedConversation/  # Agent conversation normalizer
│   │   ├── agents/                  # Agent-specific UI components
│   │   ├── common/                  # Shared UI primitives
│   │   ├── dialogs/                 # Modal dialog system
│   │   │   ├── auth/                # Authentication dialogs
│   │   │   ├── git/                 # Git operations dialogs
│   │   │   ├── global/              # Global settings/actions
│   │   │   ├── org/                 # Organization management
│   │   │   ├── projects/            # Project CRUD dialogs
│   │   │   ├── scripts/             # Script execution dialogs
│   │   │   ├── settings/            # Settings configuration
│   │   │   ├── shared/              # Shared dialog components
│   │   │   ├── tasks/               # Task management dialogs
│   │   │   └── wysiwyg/             # Rich text editing dialogs
│   │   ├── diff/                    # Git diff visualization
│   │   ├── ide/                     # IDE-style file browser
│   │   ├── layout/                  # App layout structure
│   │   ├── legacy-design/           # Legacy UI components (migration path)
│   │   ├── logs/                    # Execution log display
│   │   ├── org/                     # Organization UI
│   │   ├── panels/                  # Resizable panel system
│   │   ├── projects/                # Project list/card views
│   │   ├── rjsf/                    # JSON Schema form renderer
│   │   │   ├── fields/              # Custom RJSF field types
│   │   │   ├── templates/           # Custom RJSF templates
│   │   │   └── widgets/             # Custom RJSF widgets
│   │   ├── settings/                # Settings UI components
│   │   ├── showcase/                # Component showcase/demo
│   │   ├── tasks/                   # Task UI components
│   │   │   ├── TaskDetails/         # Task detail view
│   │   │   ├── Toolbar/             # Task toolbar actions
│   │   │   └── follow-up/           # Follow-up conversation UI
│   │   ├── ui/                      # Base UI library (shadcn-based)
│   │   │   ├── shadcn-io/           # shadcn/ui port components
│   │   │   ├── table/               # Table components
│   │   │   └── wysiwyg/             # Lexical rich text editor
│   │   └── ui-new/                  # New design system (Container/View)
│   │       ├── actions/             # Action button components
│   │       ├── containers/          # Data container components
│   │       ├── dialogs/             # Dialog wrappers
│   │       ├── hooks/               # Design-system hooks
│   │       ├── primitives/          # Base primitives
│   │       ├── scope/               # Scoped context components
│   │       ├── terminal/            # xterm.js terminal views
│   │       ├── types/               # Design system types
│   │       └── views/               # Stateless view components
│   ├── contexts/                    # 25 React Context providers
│   │   ├── remote/                  # Remote/cloud context providers
│   │   ├── DiffContext.tsx          # Diff viewer state
│   │   ├── ExecutionProcessContext.tsx
│   │   ├── ProjectContext.tsx       # Active project state
│   │   ├── TaskContext.tsx          # Active task state
│   │   ├── WorkspaceContext.tsx     # Active workspace state
│   │   └── ...                      # 20 more context files
│   ├── hooks/                       # Custom React hooks
│   │   ├── auth/                    # Authentication hooks
│   │   ├── useConversationHistory/  # Conversation history management
│   │   ├── useProject.ts            # Project data hooks
│   │   ├── useTask.ts               # Task data hooks
│   │   ├── useWorkspace.ts          # Workspace data hooks
│   │   └── ...                      # Many more domain hooks
│   ├── stores/                      # Zustand state stores
│   │   ├── useAppStore.ts           # Global app state
│   │   ├── useProjectStore.ts       # Project state
│   │   ├── useTaskStore.ts          # Task state
│   │   ├── useExecutionStore.ts     # Execution state
│   │   └── useSettingsStore.ts      # Settings state
│   ├── services/                    # API client layer
│   │   ├── __tests__/               # API service tests
│   │   ├── api.ts                   # Base API client (fetch wrapper)
│   │   ├── projects.ts              # Project API calls
│   │   ├── tasks.ts                 # Task API calls
│   │   ├── workspaces.ts            # Workspace API calls
│   │   └── ...                      # 13 API namespaces total
│   ├── pages/                       # Route page components
│   │   ├── settings/                # Settings pages
│   │   └── ui-new/                  # New design system pages
│   ├── i18n/                        # Internationalization
│   │   └── locales/                 # 7 language translations
│   │       ├── en/                  # English (primary)
│   │       ├── es/                  # Spanish
│   │       ├── fr/                  # French
│   │       ├── ja/                  # Japanese
│   │       ├── ko/                  # Korean
│   │       ├── zh-Hans/             # Simplified Chinese
│   │       └── zh-Hant/             # Traditional Chinese
│   ├── keyboard/                    # Keyboard shortcut system
│   ├── lib/                         # Utility libraries
│   │   ├── auth/                    # Auth helper functions
│   │   └── electric/                # Electric SQL sync client
│   ├── config/                      # Runtime configuration
│   ├── constants/                   # App constants
│   ├── mock/                        # Mock data for testing
│   ├── styles/                      # CSS styling
│   │   ├── legacy/                  # Legacy CSS (migration path)
│   │   └── new/                     # New design system CSS
│   ├── test/                        # Test utilities and setup
│   ├── types/                       # TypeScript type definitions
│   ├── utils/                       # Frontend utilities
│   └── vscode/                      # VS Code integration helpers
├── CLAUDE.md                        # AI agent styling/architecture rules
├── index.html                       # Vite HTML entry
├── package.json                     # Frontend dependencies (95+)
├── tsconfig.json                    # TypeScript configuration
├── vite.config.ts                   # Vite build configuration
├── tailwind.config.js               # TailwindCSS configuration
└── postcss.config.js                # PostCSS configuration
```

### Key Architectural Patterns in Frontend

| Pattern | Location | Description |
|---------|----------|-------------|
| **Container/View** | `components/ui-new/` | Data containers separate from stateless views |
| **Zustand Stores** | `stores/` | 5 global state stores for cross-component state |
| **React Context** | `contexts/` | 25 providers for scoped component state |
| **API Namespaces** | `services/` | 13 API modules matching backend routes |
| **Electric SQL** | `lib/electric/` | Real-time PostgreSQL sync via HTTP shape streams |
| **nice-modal-react** | `dialogs/` | Imperative modal management via @ebay/nice-modal |

---

## Part 3: Remote Frontend (`remote-frontend/`)

Entry point: `remote-frontend/src/main.tsx`
Purpose: SaaS portal for organizations, billing, code reviews

```
remote-frontend/
├── public/                          # Static assets
├── src/
│   ├── main.tsx                     # ENTRY POINT
│   ├── App.tsx                      # Root component
│   ├── components/                  # SaaS-specific UI components
│   │   ├── ReviewPage/              # PR review interface
│   │   ├── BillingPage/             # Stripe billing UI
│   │   └── OrgManagement/           # Organization admin
│   ├── lib/                         # Utility functions
│   ├── pages/                       # Route pages
│   ├── styles/                      # CSS styling
│   └── types/                       # TypeScript types
├── package.json                     # Separate React dependencies
├── tsconfig.json                    # TypeScript config
└── vite.config.ts                   # Vite build config
```

---

## Part 4: Shared Types (`shared/`)

Purpose: Auto-generated TypeScript types from Rust structs via ts-rs

```
shared/
├── types.ts                         # GENERATED - All local server types
├── remote-types.ts                  # GENERATED - Remote server types
└── schemas/                         # JSON Schema for agent executor configs
    ├── claude_code.json             # Claude Code settings schema
    ├── amp.json                     # Amplify settings schema
    ├── gemini.json                  # Gemini CLI settings schema
    ├── codex.json                   # Codex settings schema
    ├── cursor_agent.json            # Cursor settings schema
    ├── copilot.json                 # Copilot settings schema
    ├── droid.json                   # Droid settings schema
    ├── opencode.json                # OpenCode settings schema
    └── qwen_code.json              # Qwen Code settings schema
```

---

## Part 5: NPX CLI Wrapper (`npx-cli/`)

Purpose: npm distribution package that downloads platform-specific Rust binaries

```
npx-cli/
├── bin/
│   ├── cli.js                       # ENTRY POINT - Selects platform binary
│   └── download.js                  # Downloads binary from Cloudflare R2
├── package.json                     # npm package manifest (vibe-kanban)
└── README.md                        # CLI usage instructions
```

---

## Part 6: Remote Backend (`crates/remote/`)

See the `crates/remote/` section in Part 1 above. This is a separate application
with its own PostgreSQL database, authentication system, and deployment.

---

## Integration Points Between Parts

```
                    ┌─────────────────────────────┐
                    │     npx-cli (Part 5)        │
                    │  Downloads binary from R2   │
                    └──────────┬──────────────────┘
                               │ launches
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                    Local Server (Part 1)                      │
│  crates/server → crates/services → crates/db (SQLite)       │
│                         │                                     │
│         ┌───────────────┼──────────────────┐                 │
│         │               │                  │                  │
│    crates/git      crates/executors    crates/deployment     │
│  (worktrees)     (9 AI agents)       (trait abstraction)     │
│         │               │                  │                  │
│         │               │     ┌────────────┘                 │
│         │               │     │  implements                  │
│         │               │     ▼                              │
│         │               │  crates/local-deployment           │
│         │               │  (LocalDeployment for SQLite)      │
└─────────┼───────────────┼────────────────────────────────────┘
          │               │
          │               │ spawns child processes
          │               ▼
          │        AI Coding Agents
          │   (Claude, Gemini, Codex, etc.)
          │
          │                    HTTP/SSE/WS
┌─────────┼────────────────────────────────┐
│         │     Frontend (Part 2)          │
│         │  React SPA (Vite)              │
│         │         │                      │
│         │    imports types               │
│         │         ▼                      │
│         │  shared/types.ts (Part 4)      │
│         │  (generated by ts-rs)          │
└─────────┼────────────────────────────────┘
          │
          │ embedded via rust-embed at /
          ▼
    Served as static files from Rust binary

┌──────────────────────────────────────────┐
│      Remote Server (Part 6)              │
│  crates/remote → PostgreSQL              │
│  JWT auth, OAuth, Stripe, GitHub App     │
│         │                                │
│    Electric SQL sync proxy               │
│         │                                │
│         ▼                                │
│  Remote Frontend (Part 3)                │
│  SaaS portal (reviews, billing, orgs)    │
└──────────────────────────────────────────┘
```

### Integration Summary

| From | To | Protocol | Purpose |
|------|----|----------|---------|
| Frontend | Local Server | HTTP REST + SSE + WebSocket | All app operations |
| Frontend | Shared Types | TypeScript import | Type safety |
| Local Server | AI Agents | Child process (stdin/stdout) | Agent execution |
| Local Server | Remote Server | HTTP REST | OAuth, PR sync, issue sync |
| Local Server | Git Repos | libgit2 (git2-rs) | Worktree, branch, diff |
| Remote Server | PostgreSQL | SQLx connection pool | Data persistence |
| Remote Server | GitHub | GitHub App API + Webhooks | PR reviews |
| Remote Server | Stripe | Stripe API | Billing |
| Remote Server | Electric SQL | Proxy pass-through | Real-time sync to frontend |
| NPX CLI | Cloudflare R2 | HTTP download | Binary distribution |
| ts-rs Generator | Shared Types | File generation | Rust -> TypeScript types |

---

## Critical Directories (Deep Scan Findings)

### Backend Critical Paths

| Directory | Files | Purpose | Key Finding |
|-----------|-------|---------|-------------|
| `crates/server/src/routes/` | 21 | All API endpoint handlers | 50+ endpoints, SSE/WS streaming |
| `crates/services/src/services/` | 27 | Business logic layer | Central orchestration point |
| `crates/executors/src/executors/` | 9 | AI agent implementations | Each agent has unique CLI integration |
| `crates/db/migrations/` | 44 | Database evolution | Major refactors: workspaces, multi-repo |
| `crates/db/src/models/` | 11 | Data model structs | 16 SQLite tables |
| `crates/git/src/` | 3 | Git operations | 1953-line GitService, worktree isolation |
| `crates/remote/src/routes/` | 15+ | Remote API routes | 60+ endpoints, JWT + OAuth |
| `crates/remote/src/auth/` | 3 | Auth system | JWT + AES-256-GCM encryption |

### Frontend Critical Paths

| Directory | Files | Purpose | Key Finding |
|-----------|-------|---------|-------------|
| `frontend/src/components/` | 90+ | React component library | Container/View architecture |
| `frontend/src/components/ui-new/` | 40+ | New design system | Active migration from legacy |
| `frontend/src/contexts/` | 25 | React Contexts | Heavy context-based state |
| `frontend/src/stores/` | 5 | Zustand stores | Global cross-component state |
| `frontend/src/services/` | 13 | API client layer | Matches backend route structure |
| `frontend/src/hooks/` | 30+ | Custom React hooks | Domain-specific data hooks |
| `frontend/src/i18n/locales/` | 7 | Translations | 7 language support |

---

## Entry Points Summary

| Part | Entry Point | Binary/Script | Description |
|------|-------------|---------------|-------------|
| Local Server | `crates/server/src/main.rs` | `server` | Axum HTTP server with embedded frontend |
| Frontend | `frontend/src/main.tsx` | N/A (embedded) | React SPA mounted at `/` |
| Remote Server | `crates/remote/src/bin/remote.rs` | `remote` | Cloud Axum server with PostgreSQL |
| Remote Frontend | `remote-frontend/src/main.tsx` | N/A (deployed) | SaaS portal SPA |
| NPX CLI | `npx-cli/bin/cli.js` | `npx vibe-kanban` | Platform binary downloader |
| Type Generator | `crates/server/src/bin/generate_types.rs` | `generate_types` | ts-rs TypeScript generation |
| Review CLI | `crates/review/src/main.rs` | `review` | Standalone PR review tool |
| DB Migrator | `crates/remote/src/bin/migrate.rs` | `migrate` | PostgreSQL migration runner |

---

## File Statistics

| Area | Directories | Key Files | Description |
|------|-------------|-----------|-------------|
| Rust crates (local) | 9 crates | ~130 source files | Backend application logic |
| Rust crate (remote) | 1 crate | ~50 source files | Cloud backend |
| Frontend | 30+ dirs | ~200 components | React SPA |
| Remote Frontend | 5 dirs | ~20 components | SaaS portal |
| Shared | 2 dirs | 11 files | Generated types + schemas |
| NPX CLI | 2 dirs | 4 files | Distribution wrapper |
| Migrations (SQLite) | 1 dir | 44 files | Local DB schema |
| Migrations (PostgreSQL) | 1 dir | 25+ files | Remote DB schema |
| CI/CD | 2 dirs | 3 workflows | GitHub Actions |
| Documentation | 10+ dirs | 30+ files | Mintlify + generated docs |

---

*Generated by BMAD Document Project Workflow v1.2.0 (Deep Scan)*
