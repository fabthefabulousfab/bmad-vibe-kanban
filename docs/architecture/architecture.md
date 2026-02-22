---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-02-22'
inputDocuments:
  - docs/prd/prd.md
  - docs/docs-vibe-kanban/architecture.md
  - docs/docs-vibe-kanban/index.md
  - docs/docs-vibe-kanban/project-overview.md
  - docs/docs-vibe-kanban/data-models.md
  - docs/docs-vibe-kanban/api-contracts.md
  - docs/docs-vibe-kanban/component-inventory.md
  - docs/docs-vibe-kanban/source-tree-analysis.md
  - docs/docs-vibe-kanban/development-guide.md
  - docs/docs-vibe-kanban/integration-architecture.md
  - docs/docs-vibe-kanban/BUILD-GUIDE.md
  - _bmad-output/analysis/reconciliation-report.md
workflowType: 'architecture'
project_name: 'bmad-vibe-kanban'
user_name: 'Fabulousfab'
date: '2026-02-19'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**

The PRD defines 66 functional requirements across 12 capability domains. Architecturally, these cluster into three tiers:

1. **Core Desktop Platform (FR1-FR47)**: Local-first functionality including project/task/workspace CRUD, AI agent execution with real-time streaming, git worktree isolation, approval system, file browsing, code search, terminal access, and configuration management. This tier is self-contained and operates entirely on SQLite with no network dependency.

2. **Cloud Collaboration (FR48-FR60)**: Organization management, issue tracking (Kanban), PR review automation, GitHub App integration, and ElectricSQL sync. This tier requires PostgreSQL, OAuth providers, and external service integrations (GitHub, Stripe).

3. **Extension Points (FR61-FR66)**: Billing, notifications, and MCP server. These are integration-heavy features that extend the platform for team/enterprise use.

The brownfield analysis confirms all FR1-FR47 requirements are fully implemented. FR48-FR66 are implemented on the cloud platform (remote crate). The architecture must document these as existing decisions, not greenfield choices.

**Non-Functional Requirements:**

28 NFRs drive critical architectural constraints:

- **Performance (NFR1-6)**: Sub-3s startup, sub-500ms SSE latency, sub-2s worktree creation, sub-1s code search. These are met by the current Rust/SQLite/embedded-SPA architecture.
- **Security (NFR7-12)**: Origin validation (CSRF), OAuth token disk protection, AES-256-GCM JWT encryption at rest, organization-level access control, webhook secret validation, no hardcoded credentials.
- **Scalability (NFR13-16)**: 100+ concurrent workspaces on SQLite, 25+ PostgreSQL tables with indexing, 10K broadcast channel capacity, 6-platform binary distribution.
- **Reliability (NFR17-20)**: Git safety guarantees, execution failure capture, PR monitor recovery, ElectricSQL reconnection handling.
- **Integration (NFR21-24)**: Executor trait normalization, dual GitHub auth (OAuth + installation token), Stripe lifecycle webhooks, ts-rs type synchronization.
- **Maintainability (NFR25-28)**: 10-crate layered hierarchy, Container/View frontend pattern, sequential migration management, auto-generated TypeScript types.

**Scale & Complexity:**

- Primary domain: Full-stack desktop application + SaaS platform
- Complexity level: High
- Estimated architectural components: 10 Rust crates, 5 Zustand stores, 25 React Context providers, 220+ React components, 17 SQLite tables, 25+ PostgreSQL tables, 50+ local API endpoints, 60+ remote API endpoints

### Technical Constraints & Dependencies

**Language & Runtime Constraints:**
- Rust nightly (nightly-2025-12-04) required for async traits and advanced features
- Node.js >= 18 + pnpm 10.13.1 for frontend build
- libgit2 (git2-rs) for all git operations -- no shelling out to git CLI
- SQLite with DELETE journal mode for cross-platform compatibility

**Distribution Constraints:**
- Single binary must embed React SPA via rust-embed
- 6 platform targets (macOS Intel/ARM, Linux x64/ARM64, Windows x64/ARM64)
- macOS code signing and notarization required
- npx CLI wrapper with Cloudflare R2 CDN for binary delivery

**Integration Constraints:**
- Each AI coding agent has its own CLI binary, log format, and capabilities
- GitHub App requires webhook endpoint on cloud platform
- ElectricSQL requires persistent PostgreSQL connection
- Stripe requires webhook endpoint for billing lifecycle

**Known Documentation Drift:**
- Migration count: docs say 44, reality is 69 (36% undocumented)
- Service count: docs say 27, reality is ~29 files with 14 exposed via Deployment trait
- Table count: docs say 16, reality is 17 (missing task_images junction table)
- Several phantom script references in operational documentation

### Cross-Cutting Concerns Identified

1. **Real-time Event Propagation**: SQLite hooks -> JSON Patches -> MsgStore -> SSE/WebSocket affects every data-modifying operation. Any new feature that writes to the database must consider event hook registration and patch generation.

2. **Type Synchronization**: Rust models annotated with `#[derive(TS)]` auto-generate TypeScript types via ts-rs. All data model changes must maintain this pipeline or risk frontend/backend type drift.

3. **Deployment Trait Abstraction**: Any new service must be integrated into both the trait definition and the LocalDeployment implementation. The pattern is service locator, not dependency injection.

4. **Git Worktree Safety**: Worktree operations must never corrupt the parent repository. All workspace lifecycle operations (create, merge, archive, cleanup) must handle edge cases (orphaned worktrees, failed checkouts, concurrent operations).

5. **Multi-Agent Normalization**: The Executor trait must normalize vastly different CLI tools. New agent integrations must implement spawn, follow-up, log normalization, and capability flags.

6. **Authentication Boundary**: Local server uses origin validation (CSRF-like). Remote server uses JWT with OAuth. The RemoteClient bridges these worlds. Any feature spanning local-to-remote must handle both auth models.

7. **Schema Migration Discipline**: 69 sequential migrations enforce backward compatibility. The split of task_attempts -> workspaces + sessions (migration 20251216142123) is the most significant schema evolution and demonstrates the migration complexity pattern.

## Technology Stack Evaluation (Brownfield)

### Primary Technology Domain

Full-stack desktop application + SaaS platform. This is a **brownfield** project with a fully operational codebase -- the technology stack is established and in production use. This section documents existing choices and evaluates their continued suitability.

### Established Technology Stack

**Backend (Rust + Axum):**
- Language: Rust (nightly-2025-12-04)
- Web framework: Axum 0.8.4
- ORM: sqlx with compile-time query checking
- Git operations: git2-rs (libgit2 bindings)
- Frontend embedding: rust-embed
- Async runtime: Tokio
- Serialization: serde + serde_json

**Frontend (React + TypeScript):**
- Framework: React 18.2.0
- Language: TypeScript 5.9.2
- Build tool: Vite 5.0.8
- Styling: TailwindCSS 3.4.0
- State management: Zustand 4.5.4 (5 stores) + React Context (25 providers)
- Real-time sync: ElectricSQL (@tanstack/electric-db-collection)
- Rich text: Lexical editor
- Code viewing: CodeMirror
- Terminal: xterm.js
- i18n: 7 language translations

**Local Database (SQLite):**
- 17 tables with 69 sequential migrations
- DELETE journal mode for cross-platform compatibility
- Event hooks for real-time JSON Patch generation
- ts-rs for automatic TypeScript type generation

**Remote Database (PostgreSQL):**
- 25+ tables for cloud collaboration
- ElectricSQL real-time sync to frontend
- sqlx with compile-time query checking

**Distribution:**
- npx CLI wrapper (vibe-kanban npm package)
- Platform-specific binaries on Cloudflare R2 CDN
- 6 build targets: macOS (Intel/ARM), Linux (x64/ARM64), Windows (x64/ARM64)
- macOS code signing (Apple Developer ID) + notarization

### Stack Suitability Assessment

| Component | Status | Assessment |
|-----------|--------|------------|
| Rust + Axum | Appropriate | High performance, single-binary distribution, memory safety. Axum is the leading async Rust web framework. |
| React 18 + TypeScript | Appropriate | Mature ecosystem, strong typing, large component library (220+ components invested). |
| Vite 5 | Appropriate | Fast development server, efficient production builds. Consider Vite 6 when stable. |
| SQLite (local) | Appropriate | Zero-config, embedded, ideal for local-first architecture. |
| PostgreSQL (remote) | Appropriate | Robust relational DB, ElectricSQL compatibility. |
| TailwindCSS | Appropriate | Utility-first CSS, consistent with React ecosystem. |
| Zustand + Context | Appropriate | Lightweight global state (Zustand) + scoped state (Context). |
| ElectricSQL | Monitor | Relatively new technology. Monitor stability and API changes. |
| rust-embed | Appropriate | Enables single-binary SPA distribution. |
| libgit2 | Appropriate | Native git operations without CLI dependency. |

**No starter template needed.** The project is operational with an established, well-suited technology stack. Future development should maintain these technology choices unless specific requirements force a change.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Existing -- Maintain):**
All critical technology decisions are already implemented and operational. The following documents them as ADRs for future reference and agent consistency.

**Deferred Decisions (Future Enhancement):**
- Cloud-native deployment mode (Deployment trait enables this but no RemoteDeployment exists yet)
- Plugin ecosystem for custom executor types
- Advanced multi-agent coordination (agents collaborating on same task)

### ADR-001: Local-First Architecture with Embedded SPA

- **Status:** Accepted (Implemented)
- **Context:** The product needs to run on developer machines with zero infrastructure dependencies. Developers must be able to start AI-assisted coding within seconds of installation, without Docker, separate databases, or cloud accounts.
- **Decision:** Build a single Rust binary that embeds the React SPA via `rust-embed`, uses SQLite for local persistence, and serves everything from `localhost`. Cloud features are additive, not required.
- **Rationale:** Single-binary distribution eliminates installation complexity. SQLite provides zero-configuration persistence. Embedding the frontend eliminates version mismatch between server and UI. The npx wrapper provides zero-install distribution.
- **Consequences:**
  - Frontend must be built before the Rust binary (build order dependency)
  - SQLite limitations (no concurrent writers from multiple processes, DELETE journal mode for compatibility)
  - Frontend bundle size directly impacts binary size
  - No server-side rendering (SPA only)
- **Affects:** FR1-FR47 (all local features), NFR1 (startup time), NFR13 (SQLite scalability)

### ADR-002: Deployment Trait as Service Locator

- **Status:** Accepted (Implemented)
- **Context:** The same HTTP route handlers need to work for both local desktop (SQLite) and cloud (PostgreSQL) deployments without code duplication.
- **Decision:** Define an abstract `Deployment` trait in `crates/deployment/` that exposes all services via accessor methods. `LocalDeployment` implements this trait for desktop use. Route handlers are generic over `D: Deployment`.
- **Rationale:** Service locator pattern provides a single access point for all services. The trait's provided methods (e.g., `stream_events`, `track_if_analytics_allowed`) share common behavior across implementations. This avoids the complexity of a full dependency injection framework.
- **Consequences:**
  - Adding a new service requires modifying the trait definition and all implementations
  - Services are not independently testable without the full Deployment context
  - Runtime service resolution (no compile-time DI guarantees)
  - Future `RemoteDeployment` can implement the same trait for cloud-native mode
- **Affects:** NFR25 (maintainability), all route handlers, service integration

### ADR-003: Git Worktree Isolation for Parallel Task Execution

- **Status:** Accepted (Implemented)
- **Context:** Developers need to run multiple AI coding agents simultaneously on the same repository without branch conflicts or cross-contamination of changes.
- **Decision:** Each workspace creates independent git worktrees for every repository in the project via `GitService`. Worktrees are created at `{worktree_base}/{workspace_id}/{repo_name}` with dedicated branches. Merging is done via squash merge back to the target branch.
- **Rationale:** Git worktrees provide native OS-level isolation without copying repository data. Shared `.git` objects mean worktree creation is fast (sub-2s for repos under 1GB). Squash merge produces clean commit history on the target branch.
- **Consequences:**
  - Worktree operations must never corrupt the parent repository
  - Cleanup must handle orphaned worktrees (72-hour auto-cleanup, 1-hour if archived)
  - Multiple worktrees increase disk usage (one working copy per workspace per repo)
  - libgit2 required for all git operations (no CLI fallback)
  - Concurrent worktree operations on the same repo require careful locking
- **Affects:** FR11-FR17 (workspace lifecycle), FR18-FR27 (agent execution), NFR3 (worktree performance), NFR17 (repository safety)

### ADR-004: Unified Executor Trait for Multi-Agent Support

- **Status:** Accepted (Implemented)
- **Context:** The platform supports 9 different AI coding agents (Claude Code, Gemini, Codex, Cursor, Copilot, Amp, QwenCode, Opencode, Droid), each with different CLI interfaces, log formats, and capabilities.
- **Decision:** Define `StandardCodingAgentExecutor` and `Executable` traits in `crates/executors/` that normalize all agents to a common interface: `spawn`, `spawn_follow_up`, `spawn_review`, `normalize_logs`, and `available_slash_commands`. Each agent implementation adapts its CLI-specific behavior to this interface.
- **Rationale:** Trait-based normalization allows the platform to treat all agents identically at the service layer. Route handlers and workspace management code never need to know which specific agent is running. New agents can be added by implementing the trait without changing existing code.
- **Consequences:**
  - Each new agent requires a full trait implementation (spawn, log normalization, capability flags)
  - Lowest-common-denominator features limit what can be exposed uniformly
  - Agent-specific capabilities exposed via feature flags (`SessionFork`, `SetupHelper`, `ContextUsage`)
  - MCP server configuration varies per agent type
  - Log normalization must handle each agent's unique output format
- **Affects:** FR18-FR27 (agent execution), NFR21 (executor normalization)

### ADR-005: Event Sourcing Lite via SQLite Hooks

- **Status:** Accepted (Implemented)
- **Context:** The frontend needs real-time updates whenever any data changes in the backend database, without polling and without complex message queue infrastructure.
- **Decision:** Register SQLite preupdate hooks that fire on INSERT/UPDATE/DELETE. The `EventService` generates RFC 6902 JSON Patches for affected records and pushes them to `MsgStore` (in-memory broadcast channel with 10K capacity and 100MB FIFO history buffer). Frontend subscribes via SSE at `/api/events` and applies patches locally.
- **Rationale:** SQLite hooks provide change detection at the database level, catching all mutations regardless of which service triggered them. JSON Patch (RFC 6902) is a standardized format for incremental state updates. The MsgStore history buffer allows late-joining subscribers to catch up without re-querying.
- **Consequences:**
  - Every database table that needs real-time updates must have hook registration
  - MsgStore memory usage grows with history (100MB cap with FIFO eviction)
  - JSON Patch generation adds overhead to every write operation
  - Frontend must implement patch application logic (rfc6902 library)
  - No guaranteed delivery (broadcast channel can drop messages if buffer full)
- **Affects:** FR31-FR34 (real-time communication), NFR2 (SSE latency), NFR15 (broadcast capacity)

### ADR-006: Dual Database Architecture (SQLite + PostgreSQL)

- **Status:** Accepted (Implemented)
- **Context:** The product serves two deployment modes: local desktop (single user, offline capable) and cloud platform (multi-tenant, always-connected). These have fundamentally different data persistence needs.
- **Decision:** Use SQLite for the local desktop application (17 tables, embedded in process) and PostgreSQL for the cloud platform (25+ tables, ElectricSQL sync). Both use sqlx with compile-time query checking. Schema managed via sequential migrations (69 for SQLite, 25+ for PostgreSQL).
- **Rationale:** SQLite is ideal for local-first: zero-config, single-file, embedded. PostgreSQL is ideal for cloud: relational integrity, ElectricSQL compatibility, multi-tenant queries. Using sqlx for both keeps the ORM layer consistent.
- **Consequences:**
  - Two separate migration chains to maintain
  - Data synchronization between local and remote requires migration_state table
  - No shared ORM models between local and remote (different schemas)
  - SQLite's DELETE journal mode limits concurrent write performance
  - Type generation (ts-rs) only covers local models; remote types are separate
- **Affects:** FR58 (data sync), NFR13-14 (scalability), NFR20 (ElectricSQL reconnection)

### ADR-007: Cross-Platform Binary Distribution via npx

- **Status:** Accepted (Implemented)
- **Context:** The product must be easy to install across macOS (Intel/ARM), Linux (x64/ARM64), and Windows (x64) without requiring developers to install Rust toolchains, Docker, or other infrastructure.
- **Decision:** Distribute via npm as `vibe-kanban`. The npx CLI wrapper detects the platform, downloads the appropriate pre-compiled Rust binary from Cloudflare R2, caches it locally at `~/.vibe-kanban/bin/`, and executes it. GitHub Actions builds binaries for all 6 platform targets.
- **Rationale:** npm is universally available in developer environments. npx provides zero-install execution. Cloudflare R2 provides global CDN delivery. Platform detection is handled automatically.
- **Consequences:**
  - Build pipeline must compile for 6 targets (GitHub Actions matrix)
  - macOS binaries require Apple Developer ID signing and notarization
  - Binary size must be managed (Rust + embedded frontend)
  - Version management handled by npx cache + R2 bucket versioning
  - No auto-update mechanism beyond npx version checking
- **Affects:** NFR16 (cross-platform distribution), build process, release workflow

### Decision Impact Analysis

**Implementation Sequence:**
All decisions are already implemented. For new features, the sequence is:
1. Define data model (SQLite migration + ts-rs annotation)
2. Add service logic (crates/services/)
3. Register in Deployment trait if needed (crates/deployment/)
4. Implement in LocalDeployment (crates/local-deployment/)
5. Add route handlers (crates/server/src/routes/)
6. Register SQLite hooks for real-time events if needed
7. Build frontend components (Container/View pattern)
8. Add API client (frontend/src/services/)
9. Connect via Zustand/Context state management

**Cross-Component Dependencies:**
- ADR-001 (local-first) + ADR-005 (event sourcing) = real-time local experience
- ADR-002 (deployment trait) + ADR-006 (dual DB) = same routes serve both deployments
- ADR-003 (worktrees) + ADR-004 (executor trait) = isolated parallel agent execution
- ADR-005 (events) + ADR-006 (SQLite) = hooks are SQLite-specific; PostgreSQL uses ElectricSQL instead

## Implementation Patterns & Consistency Rules

### Critical Conflict Points Identified

12 areas where AI agents could make different implementation choices. The following patterns ensure consistency.

### Naming Patterns

**Database Naming Conventions:**
- Tables: `snake_case`, plural (`workspaces`, `execution_processes`, `coding_agent_turns`)
- Columns: `snake_case` (`created_at`, `workspace_id`, `target_branch`)
- Foreign keys: `{referenced_table_singular}_id` (`project_id`, `repo_id`, `session_id`)
- Junction tables: `{table1}_{table2}` (`project_repos`, `workspace_repos`, `task_images`)
- Indexes: follow sqlx migration conventions
- Enums stored as TEXT with CHECK constraints (`status TEXT CHECK(status IN ('running','completed','failed','killed'))`)

**API Naming Conventions:**
- Endpoints: `snake_case` with hyphens for multi-word resources (`/task-attempts`, `/execution-processes`, `/coding-agent-turns`)
- Route parameters: `:id` format (`/tasks/:id`, `/execution-processes/:id/stream`)
- Query parameters: `snake_case` (`?workspace_id=`, `?repo_ids=`)
- HTTP methods: standard REST (GET list, GET by ID, POST create, PUT update, DELETE remove)
- SSE endpoints: append `/stream` to resource path
- WebSocket endpoints: append `/ws` to resource path

**Rust Code Naming:**
- Structs: `PascalCase` (`WorkspaceRepo`, `ExecutionProcess`, `CodingAgentTurn`)
- Functions: `snake_case` (`find_all`, `find_by_workspace_id`, `create_workspace`)
- Modules: `snake_case` (`container_service`, `workspace_service`)
- Enums: `PascalCase` variants (`TaskStatus::InProgress`, `ExecutionProcessStatus::Running`)
- Crate names: `kebab-case` in Cargo.toml (`local-deployment`, `workspace-utils`)

**Frontend Code Naming:**
- Components: `PascalCase` files and exports (`TaskDetails.tsx`, `WorkspaceContainer.tsx`)
- Hooks: `camelCase` with `use` prefix (`useTask`, `useWorkspace`, `useExecutionStore`)
- Stores: `camelCase` with `use` prefix and `Store` suffix (`useAppStore`, `useProjectStore`)
- Services: `camelCase` module files (`projects.ts`, `workspaces.ts`, `tasks.ts`)
- Contexts: `PascalCase` with `Context` suffix (`ProjectContext`, `WorkspaceContext`)
- CSS classes: TailwindCSS utility classes (no custom class naming needed)

### Structure Patterns

**Backend Organization (by layer, not by feature):**
```
crates/
  server/src/routes/      -- HTTP handlers (thin, delegate to services)
  services/src/services/  -- Business logic (all orchestration here)
  db/src/models/           -- Data models (structs + queries)
  db/migrations/           -- Sequential SQL migrations
  executors/src/executors/ -- One file per AI agent
  git/src/                 -- Git operations (single GitService)
  deployment/src/          -- Abstract trait
  local-deployment/src/    -- Concrete implementation
  utils/src/               -- Shared types, MsgStore, API types
```

**Frontend Organization (hybrid feature + type):**
```
frontend/src/
  components/ui-new/       -- New design system (Container/View)
    containers/            -- Data-fetching components
    views/                 -- Stateless display components
    primitives/            -- Base UI elements
    dialogs/               -- Dialog wrappers
  contexts/                -- React Context providers
  stores/                  -- Zustand global stores
  hooks/                   -- Custom React hooks
  services/                -- API client modules
  i18n/locales/            -- Translation files
  pages/                   -- Route page components
  types/                   -- TypeScript type definitions
```

**Test Organization:**
- Backend: `cargo test` in each crate, tests in `src/` alongside code or in `tests/` directory
- Frontend: `__tests__/` directories co-located with services (`frontend/src/services/__tests__/`)
- Shared test utilities in `frontend/src/test/`

### Format Patterns

**API Response Format:**
All local API endpoints return direct JSON responses (no wrapper). Errors use Axum's standard error handling via `AppError` with HTTP status codes.

```rust
// Success: direct JSON body
// GET /api/tasks -> [Task, Task, ...]
// GET /api/tasks/:id -> Task
// POST /api/tasks -> Task (created)

// Error: AppError with status code
pub struct AppError {
    status: StatusCode,
    message: String,
}
```

**Data Exchange Formats:**
- JSON field naming: `snake_case` (consistent with Rust serde defaults)
- Dates: ISO 8601 strings (`"2026-02-19T12:34:56Z"`)
- UUIDs: Standard UUID v4 format as strings
- Booleans: `true`/`false` (JSON native)
- Null handling: omit field or explicit `null` (serde `skip_serializing_if = "Option::is_none"`)
- IDs stored as BLOB in SQLite, serialized as UUID strings in JSON

**Real-time Event Format:**
- JSON Patch (RFC 6902) for database change events
- SSE `data:` field contains serialized `LogMsg` enum variants
- LogMsg types: `Stdout`, `Stderr`, `JsonPatch`, `SessionId`, `MessageId`, `Finished`

### Communication Patterns

**Event System:**
- Event naming: implicit (tied to table + operation, not named events)
- Event payload: RFC 6902 JSON Patch with `op`, `path`, `value`
- Delivery: SSE for unidirectional streams, WebSocket for bidirectional (terminal, scratch)
- History: MsgStore provides 100MB FIFO buffer for late-joining subscribers
- Supported tables for events: projects, tasks, workspaces, sessions, execution_processes, scratch, images, tags, merges

**State Management (Frontend):**
- Zustand stores for cross-component global state (5 stores)
- React Context for scoped component state (25 providers)
- State updates: immutable (Zustand `set()` with spread operator)
- SSE patches applied via `rfc6902.applyPatch()` to local state
- No Redux, no MobX, no other state management libraries

### Process Patterns

**Error Handling (Backend):**
```rust
// Route handlers return Result<Json<T>, AppError>
// AppError maps to HTTP status codes
// Services return Result<T, Error> with domain-specific errors
// All errors logged; user-facing messages sanitized
```

**Error Handling (Frontend):**
- API errors caught in service layer, propagated via return types
- Error boundaries for component-level crash recovery
- Toast notifications for user-facing errors

**Loading States:**
- Zustand stores track loading per-entity (not global loading flag)
- Components use Container pattern: Container handles loading/error, View receives clean data
- SSE subscriptions provide real-time updates (no polling for data changes)

**Execution Process Lifecycle:**
```
Created -> Running -> Completed | Failed | Killed
                        |
                  exit_code captured
                  completed_at set
```

### Enforcement Guidelines

**All AI Agents MUST:**
- Follow the naming conventions exactly as documented above
- Place new files in the correct layer (routes in routes/, services in services/, models in models/)
- Register new SQLite tables in event hooks if they need real-time updates
- Annotate new Rust models with `#[derive(TS)]` for TypeScript generation
- Add new services to the Deployment trait and LocalDeployment implementation
- Write sequential migrations (never modify existing migration files)
- Use the Container/View pattern for new frontend components
- Import types from `shared/types.ts` (never duplicate type definitions)

**Anti-Patterns to Avoid:**
- Putting business logic in route handlers (use services layer)
- Creating new Zustand stores (use existing 5 stores or React Context)
- Shelling out to git CLI (use GitService via libgit2)
- Hardcoding configuration values (use Config service or environment variables)
- Mutating state directly (always use immutable updates)
- Using `console.log` in production code
- Creating global error handlers that swallow errors silently

## Project Structure & Boundaries

### Complete Project Directory Structure

```
bmad-vibe-kanban/
|-- .cargo/                          # Cargo build configuration
|-- .github/
|   |-- actions/setup-node/          # Reusable Node.js setup action
|   +-- workflows/
|       |-- test.yml                 # PR checks: lint, format, type-check, cargo test
|       |-- pre-release.yml          # 6-platform build matrix, signing, R2 upload
|       +-- publish.yml              # npm publish with OIDC
|-- _bmad/                           # BMAD methodology framework
|-- assets/
|   |-- scripts/                     # Shell scripts bundled into binary
|   +-- sounds/                      # Notification sound files
|-- crates/                          # Rust workspace (10 crates)
|   |-- server/                      # ENTRY POINT: Axum HTTP server
|   |   +-- src/
|   |       |-- main.rs              # 15-step startup sequence
|   |       |-- error.rs             # AppError with HTTP status mapping
|   |       |-- bin/
|   |       |   |-- server.rs        # Binary entry point
|   |       |   +-- generate_types.rs # ts-rs type generator
|   |       |-- routes/              # 50+ API endpoint handlers
|   |       |-- middleware/          # Origin validation, model loaders
|   |       +-- mcp/                 # MCP server (rmcp-based)
|   |-- db/                          # Database layer
|   |   |-- src/models/              # 17 SQLite model structs
|   |   |-- migrations/              # 69 sequential SQL migrations
|   |   +-- .sqlx/                   # Offline query verification cache
|   |-- services/                    # Business logic (29 service modules)
|   |   +-- src/services/
|   |-- executors/                   # 9 AI agent implementations
|   |   +-- src/
|   |       |-- lib.rs               # Executor trait
|   |       |-- executors/           # claude_code, amp, gemini, codex, cursor, opencode, qwen, copilot, droid
|   |       |-- actions/             # Shared executor actions
|   |       +-- logs/                # Log parsing and streaming
|   |-- git/                         # Git operations (libgit2)
|   |   +-- src/lib.rs              # GitService (1953 lines)
|   |-- deployment/                  # Abstract Deployment trait
|   |-- local-deployment/            # LocalDeployment (SQLite)
|   |-- remote/                      # Cloud backend (PostgreSQL)
|   |   +-- src/
|   |       |-- app.rs               # Axum app builder
|   |       |-- auth/                # JWT + OAuth + AES-256-GCM
|   |       |-- routes/              # 60+ remote API routes
|   |       |-- db/                  # 25+ PostgreSQL models
|   |       |-- github_app/          # GitHub App webhooks
|   |       +-- middleware/          # JWT auth + org access control
|   |-- review/                      # Standalone PR review CLI
|   +-- utils/                       # Shared utilities + ts-rs bindings
|-- frontend/                        # React SPA (embedded in binary)
|   |-- public/                      # Static assets
|   +-- src/
|       |-- main.tsx                 # Entry point
|       |-- App.tsx                  # Root with providers
|       |-- components/              # 220+ React components
|       |   |-- ui-new/              # New design system (Container/View)
|       |   |   |-- containers/
|       |   |   |-- views/
|       |   |   |-- primitives/
|       |   |   +-- dialogs/
|       |   |-- dialogs/             # Modal dialog system
|       |   |-- diff/                # Git diff visualization
|       |   |-- ide/                 # File browser
|       |   |-- logs/                # Execution log display
|       |   +-- ui/                  # Base UI library (shadcn-based)
|       |-- contexts/                # 25 React Context providers
|       |-- stores/                  # 5 Zustand stores
|       |-- hooks/                   # Custom React hooks (30+)
|       |-- services/                # 13 API client modules
|       |-- i18n/locales/            # 7 language translations
|       |-- pages/                   # Route page components
|       |-- lib/electric/            # ElectricSQL sync client
|       |-- keyboard/                # Keyboard shortcut system
|       +-- types/                   # TypeScript type definitions
|-- remote-frontend/                 # SaaS portal SPA
|   +-- src/
|       |-- components/              # Org, billing, PR review UI
|       +-- pages/                   # Route pages
|-- shared/                          # Generated TypeScript types
|   |-- types.ts                     # Local server types (ts-rs)
|   |-- remote-types.ts              # Remote server types
|   +-- schemas/                     # JSON Schema for executor configs
|-- npx-cli/                         # npm distribution wrapper
|   +-- bin/
|       |-- cli.js                   # Platform detection + launch
|       +-- download.js              # Binary download from R2
|-- docs/                            # Documentation
|-- Cargo.toml                       # Rust workspace manifest
|-- package.json                     # Root Node.js manifest
|-- pnpm-workspace.yaml              # pnpm workspace config
|-- build-vibe-kanban.sh             # Full build script
|-- local-build.sh                   # Local development build
+-- quick-check.sh                   # Quick lint/format check
```

### Architectural Boundaries

**API Boundaries:**
- Local server: `/api/*` -- all local endpoints behind origin validation middleware
- Remote server: `/v1/*` -- all remote endpoints behind JWT middleware (except public routes)
- MCP server: rmcp-based tool exposure (separate protocol, same binary)

**Component Boundaries:**
- Frontend -> Backend: HTTP REST + SSE + WebSocket only (no direct DB access)
- Backend routes -> Services: routes are thin wrappers, all logic in service layer
- Services -> DB: services use model query functions, never raw SQL in services
- Services -> Git: services call GitService methods, never libgit2 directly
- Local -> Remote: RemoteClient handles all HTTP communication with OAuth tokens

**Data Boundaries:**
- Local data (SQLite): owned entirely by LocalDeployment, accessed via DBService
- Remote data (PostgreSQL): owned by remote crate, accessed via remote routes
- Sync boundary: migration_state table maps local IDs to remote IDs
- Type boundary: ts-rs generates types from Rust models; frontend imports from shared/

### Requirements to Structure Mapping

**FR1-FR5 (Project Management):**
- Backend: `crates/server/src/routes/projects.rs` + `crates/services/src/services/project.rs`
- Database: `crates/db/src/models/project.rs`
- Frontend: `frontend/src/components/projects/` + `frontend/src/services/projects.ts`

**FR6-FR10 (Task Management):**
- Backend: `crates/server/src/routes/tasks.rs`
- Database: `crates/db/src/models/task.rs`
- Frontend: `frontend/src/components/tasks/` + `frontend/src/services/tasks.ts`

**FR11-FR17 (Workspace Lifecycle):**
- Backend: `crates/server/src/routes/task_attempts.rs` + `crates/services/src/services/workspace_service.rs`
- Database: `crates/db/src/models/workspace.rs`
- Git: `crates/git/src/lib.rs` (worktree operations)
- Frontend: `frontend/src/components/ui-new/containers/` + `frontend/src/services/workspaces.ts`

**FR18-FR27 (AI Agent Execution):**
- Backend: `crates/executors/src/executors/` (9 implementations)
- Orchestration: `crates/services/src/services/container_service.rs`
- Streaming: `crates/server/src/routes/execution_processes.rs` (SSE)
- Frontend: `frontend/src/components/logs/` + `frontend/src/hooks/useConversationHistory/`

**FR28-FR30 (Approval System):**
- Backend: `crates/services/src/services/approvals.rs` + `crates/server/src/routes/approvals.rs`
- Frontend: approval dialog components

**FR31-FR34 (Real-Time Communication):**
- Backend: `crates/services/src/services/event_service.rs` + `crates/utils/src/msg_store.rs`
- Delivery: `crates/server/src/routes/events.rs` (SSE/WebSocket)
- Frontend: SSE subscription hooks + rfc6902 patch application

**FR48-FR66 (Cloud Features):**
- Backend: `crates/remote/src/routes/` (organizations, issues, billing, PR reviews)
- Database: `crates/remote/src/db/` (PostgreSQL models)
- Frontend: `remote-frontend/src/` (SaaS portal)

### Data Flow

```
User Action (Frontend)
    |
    v
API Client (frontend/src/services/) -- HTTP POST/PUT/DELETE
    |
    v
Route Handler (crates/server/src/routes/) -- thin, validates, delegates
    |
    v
Service Layer (crates/services/) -- business logic, orchestration
    |
    +---> DB Write (crates/db/) -- SQLite INSERT/UPDATE/DELETE
    |         |
    |         v
    |     SQLite Hook fires
    |         |
    |         v
    |     EventService generates JSON Patch
    |         |
    |         v
    |     MsgStore broadcasts to SSE subscribers
    |         |
    |         v
    |     Frontend receives patch, applies to local state
    |
    +---> Git Operation (crates/git/) -- worktree create/merge/diff
    |
    +---> Agent Spawn (crates/executors/) -- child process
              |
              v
          Stdout/Stderr streamed via MsgStore -> SSE
```

## Architecture Validation Results

### Coherence Validation

**Decision Compatibility:**
All 7 ADRs work together without conflicts. The Deployment trait (ADR-002) enables the dual database architecture (ADR-006). The event sourcing system (ADR-005) depends on SQLite hooks, which is consistent with the local-first choice (ADR-001). The executor trait (ADR-004) operates within the worktree isolation boundary (ADR-003). The npx distribution (ADR-007) packages the embedded SPA binary (ADR-001).

**Pattern Consistency:**
Naming patterns (snake_case for DB/API, PascalCase for Rust/React types) are consistent throughout the codebase. The Container/View pattern aligns with the service layer separation on the backend. State management patterns (Zustand + Context) are well-scoped and don't overlap.

**Structure Alignment:**
The 10-crate layered hierarchy enforces proper dependency direction (server -> deployment -> services -> db/git/executors -> utils). Frontend organization mirrors backend domains. The shared types package bridges the boundary correctly.

### Requirements Coverage Validation

**Functional Requirements Coverage:**
- FR1-FR47 (Core Desktop): Fully covered by ADR-001, ADR-002, ADR-003, ADR-004, ADR-005
- FR48-FR60 (Cloud): Fully covered by ADR-006, remote crate architecture
- FR61-FR66 (Extensions): Covered by remote crate (Stripe, notifications, MCP)
- Coverage: **100%** -- all 66 FRs have architectural support

**Non-Functional Requirements Coverage:**
- NFR1-6 (Performance): Covered by Rust performance (ADR-001), SQLite (ADR-006), MsgStore sizing (ADR-005)
- NFR7-12 (Security): Covered by origin validation, OAuth, JWT encryption, webhook validation
- NFR13-16 (Scalability): Covered by SQLite DELETE mode (ADR-006), broadcast channel sizing (ADR-005), 6-platform builds (ADR-007)
- NFR17-20 (Reliability): Covered by git safety (ADR-003), execution status tracking (ADR-004), ElectricSQL reconnection
- NFR21-24 (Integration): Covered by executor trait (ADR-004), dual auth, Stripe webhooks, ts-rs
- NFR25-28 (Maintainability): Covered by crate hierarchy, Container/View, migrations, type generation
- Coverage: **100%** -- all 28 NFRs are architecturally addressed

### Implementation Readiness Validation

**Decision Completeness:** All critical decisions documented with technology versions, rationale, and consequences. 7 ADRs cover the architectural foundations.

**Structure Completeness:** Complete project tree defined with all 10 crates, frontend structure, shared types, and distribution layer. All entry points documented.

**Pattern Completeness:** Naming conventions, file organization, API format, event system, state management, and error handling patterns all specified with examples and anti-patterns.

### Architecture Completeness Checklist

**Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed (High)
- [x] Technical constraints identified (7 constraint categories)
- [x] Cross-cutting concerns mapped (7 concerns)

**Architectural Decisions**
- [x] Critical decisions documented with versions (7 ADRs)
- [x] Technology stack fully specified
- [x] Integration patterns defined
- [x] Performance considerations addressed

**Implementation Patterns**
- [x] Naming conventions established (DB, API, Rust, Frontend)
- [x] Structure patterns defined (Backend layers, Frontend Container/View)
- [x] Communication patterns specified (SSE, WebSocket, JSON Patch)
- [x] Process patterns documented (error handling, loading states, execution lifecycle)

**Project Structure**
- [x] Complete directory structure defined
- [x] Component boundaries established
- [x] Integration points mapped
- [x] Requirements to structure mapping complete

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION

**Confidence Level:** High -- this is a brownfield architecture document for an operational system. All decisions are validated by running production code.

**Key Strengths:**
- Clean layered dependency hierarchy prevents circular dependencies
- Deployment trait enables future cloud-native deployment without route handler changes
- Git worktree isolation provides true parallel execution without conflicts
- Event sourcing lite delivers real-time updates with minimal infrastructure
- Executor trait makes adding new AI agents straightforward
- ts-rs type generation eliminates frontend/backend type drift

**Areas for Future Enhancement:**
- RemoteDeployment implementation (cloud-native mode using same route handlers)
- Plugin ecosystem for custom executor types
- Advanced multi-agent coordination
- Comprehensive automated test coverage (current test infrastructure is minimal)
- Documentation reconciliation (resolve 17 known drift issues)

### Implementation Handoff

**AI Agent Guidelines:**
- Follow all architectural decisions exactly as documented in this document
- Use implementation patterns consistently across all components
- Respect project structure and layer boundaries
- Place new code in the correct crate/directory per the structure mapping
- Always annotate new models with `#[derive(TS)]` for type generation
- Write sequential migrations; never modify existing migration files
- Use Container/View pattern for new frontend components
- Register new database tables in event hooks if real-time updates needed

**New Feature Implementation Sequence:**
1. Define data model (SQLite migration + model struct with ts-rs)
2. Add service logic (crates/services/)
3. Register in Deployment trait if needed
4. Implement in LocalDeployment
5. Add route handlers (thin, delegate to services)
6. Register SQLite hooks for real-time events
7. Run `cargo run --bin generate_types` to update TypeScript types
8. Build frontend components (Container fetches data, View renders)
9. Add API client module (frontend/src/services/)
10. Connect state management (Zustand store or React Context)
