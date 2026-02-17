# Architecture Documentation

## Executive Summary

**Vibe Kanban** is a polyglot desktop application and cloud platform for AI-assisted software development. It enables developers to manage coding tasks through automated AI agents while maintaining full control through a local-first architecture. The system consists of:

- **Local Desktop Application**: Rust backend with embedded React frontend, using SQLite for data persistence
- **Cloud Platform**: Rust backend with PostgreSQL, serving a SaaS portal for organization management, PR reviews, and billing
- **Multi-Agent Orchestration**: Support for 9 different AI coding agents (Claude Code, Gemini, Codex, Cursor, etc.)
- **Git Worktree Isolation**: Each workspace gets isolated git worktrees, enabling parallel task execution across multiple repositories

**Primary Users**:
- Individual developers seeking AI-assisted coding workflows
- Development teams managing complex multi-repository projects
- Organizations requiring code review automation and team coordination

**Core Value Proposition**: Local-first development with git worktree isolation, real-time streaming of agent execution, and seamless synchronization with cloud-hosted project management.

---

## System Architecture Overview

### High-Level Component Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          DESKTOP APPLICATION                             │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                      React SPA Frontend                            │ │
│  │  (Vite, TypeScript, Zustand, React Context, Electric SQL)         │ │
│  │                                                                     │ │
│  │  Components: Container/View architecture, 90+ components           │ │
│  │  State: 5 Zustand stores + 25 React Context providers             │ │
│  │  i18n: 7 language translations                                    │ │
│  └──────────────────────┬──────────────────────────────────────────────┘ │
│                         │ HTTP REST / SSE / WebSocket                   │
│  ┌──────────────────────▼──────────────────────────────────────────────┐ │
│  │                    Rust Backend (Axum)                              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │ │
│  │  │   Routes     │  │   Services   │  │  Deployment  │             │ │
│  │  │ 50+ endpoints│→│ 27 services  │→│     Trait    │             │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘             │ │
│  │                           ▲                   ▲                     │ │
│  │  ┌────────────────────────┼───────────────────┴─────────────┐     │ │
│  │  │ LocalDeployment        │                                  │     │ │
│  │  │                        │                                  │     │ │
│  │  │  ┌──────────┐    ┌─────▼─────┐    ┌─────────────┐       │     │ │
│  │  │  │ SQLite   │    │    Git    │    │  Executors  │       │     │ │
│  │  │  │ (16 tbl) │    │  Service  │    │  (9 agents) │       │     │ │
│  │  │  │ MsgStore │    │ Worktrees │    │   Spawner   │       │     │ │
│  │  │  └──────────┘    └───────────┘    └─────────────┘       │     │ │
│  │  │        │                │                   │             │     │ │
│  │  └────────┼────────────────┼───────────────────┼─────────────┘     │ │
│  └───────────┼────────────────┼───────────────────┼───────────────────┘ │
│              │                │                   │                     │
│              │ JSON Patch     │ git worktree      │ spawn child         │
│              │ → SSE/WS       │ create/remove     │ process             │
│              ▼                ▼                   ▼                     │
│      Real-time Events   Git Repositories   AI Coding Agents            │
│      (push to frontend) (isolated worktrees) (Claude, Gemini, etc.)    │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          CLOUD PLATFORM                                  │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                   Remote Frontend (SaaS Portal)                    │ │
│  │    (Organization management, PR reviews, billing)                 │ │
│  └──────────────────────┬──────────────────────────────────────────────┘ │
│                         │ HTTP REST                                     │
│  ┌──────────────────────▼──────────────────────────────────────────────┐ │
│  │                  Remote Rust Backend (Axum)                         │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │ │
│  │  │  60+ Routes  │  │   JWT Auth   │  │  PostgreSQL  │             │ │
│  │  │              │  │ OAuth (GH/G) │  │  (25+ tables)│             │ │
│  │  │ Organizations│→│ AES-256-GCM  │→│  ElectricSQL │             │ │
│  │  │ Issues/PRs   │  │ GitHub App   │  │   Billing    │             │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘             │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
                         ▲
                         │ OAuth, Issue Sync, PR Review
                         │
              ┌──────────▼──────────┐
              │  Desktop App        │
              │  RemoteClient       │
              └─────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                      DISTRIBUTION LAYER                                  │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                       NPX CLI Wrapper                              │ │
│  │  (Downloads platform-specific binary from Cloudflare R2)          │ │
│  │  Platforms: macOS (Intel/ARM), Linux (x64/ARM64), Windows (x64)   │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Crate Dependency Hierarchy

The Rust workspace contains 10 crates organized in a clean layered architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                        ENTRY POINT                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              server (crates/server)                  │   │
│  │  - main.rs: 15-step startup sequence                │   │
│  │  - routes/: 50+ HTTP endpoint handlers              │   │
│  │  - middleware/: Origin validation, model loaders    │   │
│  │  - mcp/: Model Context Protocol server              │   │
│  └───┬────────────────────────────────────────┬─────────┘   │
└──────┼────────────────────────────────────────┼─────────────┘
       │ depends on                             │ depends on
       ▼                                        ▼
┌──────────────────────┐            ┌───────────────────────┐
│  local-deployment    │            │     deployment        │
│ (LocalDeployment)    │            │  (Deployment trait)   │
│  - Concrete impl     │ implements │  - Abstract trait     │
│  - SQLite + hooks    │◄───────────┤  - Service locator    │
│  - All services      │            │  - Provided methods   │
└──────┬───────────────┘            └───────────────────────┘
       │ depends on
       ▼
┌──────────────────────────────────────────────────────────────┐
│                      SERVICE LAYER                           │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              services (crates/services)                │ │
│  │  - 27 service modules                                 │ │
│  │  - Business logic orchestration                       │ │
│  │  - container, workspace, events, diff, PR monitor     │ │
│  └────┬─────────────┬─────────────┬───────────────────────┘ │
└───────┼─────────────┼─────────────┼──────────────────────────┘
        │             │             │
        ▼             ▼             ▼
┌────────────┐ ┌───────────┐ ┌────────────┐
│     db     │ │    git    │ │ executors  │
│ (Database) │ │ (GitOps)  │ │(AI Agents) │
│            │ │           │ │            │
│ - models/  │ │ - 1953    │ │ - 9 agent  │
│ - 16 SQLite│ │   line    │ │   impls    │
│   tables   │ │   GitSvc  │ │ - Executor │
│ - 44 migs  │ │ - Worktree│ │   trait    │
│ - ts-rs    │ │ - libgit2 │ │ - MCP cfg  │
└────────────┘ └───────────┘ └─────┬──────┘
                                   │
                                   │ depends on
                                   ▼
                            ┌──────────────┐
                            │    utils     │
                            │ (Workspace   │
                            │  Utils)      │
                            │              │
                            │ - MsgStore   │
                            │ - LogMsg     │
                            │ - API types  │
                            │ - ts-rs gen  │
                            └──────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   STANDALONE CRATES                          │
│  ┌─────────────────┐            ┌────────────────────────┐  │
│  │     remote      │            │       review           │  │
│  │ (Cloud Server)  │            │   (PR Review CLI)      │  │
│  │                 │            │                        │  │
│  │ - PostgreSQL    │            │ - Standalone tool      │  │
│  │ - JWT Auth      │            │ - Parse PR URL         │  │
│  │ - OAuth PKCE    │            │ - Clone → Upload       │  │
│  │ - 60+ routes    │            │ - Poll results         │  │
│  └─────────────────┘            └────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Summary Table

| Crate | Depends On | Key Responsibility |
|-------|-----------|-------------------|
| **server** | deployment, local-deployment, db, services, executors, git, utils | HTTP server entry point, route definitions |
| **local-deployment** | deployment, db, services, executors, git, utils | Concrete LocalDeployment implementation |
| **deployment** | db, services, executors, git, utils | Abstract Deployment trait (service locator pattern) |
| **services** | db, executors, git, utils | Business logic layer (27 services) |
| **db** | - (standalone) | SQLite models, migrations, ts-rs type generation |
| **git** | - (standalone) | Git operations via libgit2 (git2-rs) |
| **executors** | utils (as workspace_utils) | AI agent executor implementations |
| **utils** | - (standalone) | Shared utilities, MsgStore, API types |
| **remote** | - (separate app) | Cloud backend with PostgreSQL |
| **review** | - (standalone CLI) | PR review command-line tool |

---

## Architecture Patterns

### 1. Deployment Trait (Service Locator Pattern)

**Location**: `crates/deployment/src/lib.rs`

The Deployment trait abstracts access to all application services, enabling different deployment modes (local vs cloud) while maintaining a consistent interface.

**Key Methods**:
```rust
pub trait Deployment: Clone + Send + Sync + 'static {
    async fn new() -> Result<Self, DeploymentError>;

    // Service Accessors
    fn user_id(&self) -> &str;
    fn config(&self) -> &Arc<RwLock<Config>>;
    fn db(&self) -> &DBService;
    fn analytics(&self) -> &Option<AnalyticsService>;
    fn container(&self) -> &impl ContainerService;
    fn git(&self) -> &GitService;
    fn project(&self) -> &ProjectService;
    fn repo(&self) -> &RepoService;
    fn image(&self) -> &ImageService;
    fn filesystem(&self) -> &FilesystemService;
    fn events(&self) -> &EventService;
    fn file_search_cache(&self) -> &Arc<FileSearchCache>;
    fn approvals(&self) -> &Approvals;
    fn queued_message_service(&self) -> &QueuedMessageService;
    fn auth_context(&self) -> &AuthContext;
    fn remote_client(&self) -> Result<RemoteClient, RemoteClientNotConfigured>;

    // Provided Methods
    async fn trigger_auto_project_setup(&self);
    async fn stream_events(&self) -> futures::stream::BoxStream<'static, Result<Event, std::io::Error>>;
    async fn track_if_analytics_allowed(&self, event_name: &str, properties: Value);
}
```

**Implementation**: `LocalDeployment` (crates/local-deployment) implements this trait for desktop use with SQLite and local filesystem access.

**Benefit**: Future cloud-native deployment could implement the same trait without changing route handlers.

---

### 2. Service Layer (27 Services)

**Location**: `crates/services/src/services/`

All business logic is isolated in dedicated service modules, keeping route handlers thin.

**Key Services**:

| Service | Module | Responsibility |
|---------|--------|---------------|
| **ContainerService** | `container_service.rs` | Workspace lifecycle, execution process management, task finalization |
| **WorkspaceManager** | `workspace_service.rs` | Creates workspace directories with git worktrees for all repos |
| **WorktreeManager** | `worktree_manager.rs` | Low-level git worktree operations (create, remove, move) |
| **EventService** | `event_service.rs` | Real-time event streaming via MsgStore, SSE/WebSocket delivery |
| **Config** | `config.rs` | Versioned JSON config (v8), editor settings, themes |
| **ProjectService** | `project.rs` | Project CRUD, repository management, file search |
| **RepoService** | `repo.rs` | Repository CRUD, path validation, git repo detection |
| **FilesystemService** | `filesystem.rs` | Directory listing, file read/write, repo discovery |
| **FileSearchCache** | `file_search.rs` | Cached file/directory search with git history ranking |
| **GitHostProvider** | `git_host.rs` | GitHub and Azure DevOps PR management (trait-based) |
| **DiffStreamService** | `diff_stream.rs` | DiffStats computation and real-time diff streaming |
| **AnalyticsService** | `analytics.rs` | PostHog event tracking |
| **NotificationService** | `notification.rs` | Cross-platform sound and push notifications |
| **Approvals** | `approvals.rs` | Tool call approval/rejection system for coding agents |
| **RemoteClient** | `remote_client.rs` | OAuth client for remote server communication |
| **AuthContext** | `auth.rs` | Credential management (OAuth tokens, profile caching) |
| **OAuthCredentials** | `oauth_credentials.rs` | Persistent JWT token storage |
| **PrMonitorService** | `pr_monitor_service.rs` | Background task polling PR status every 60s |
| **MigrationService** | `migration.rs` | Data migration between local and remote servers |
| **QueuedMessageService** | `queued_message.rs` | Message queue for follow-up operations |

**Pattern**: Each service is instantiated in `LocalDeployment::new()` and accessed via the Deployment trait.

---

### 3. Event Sourcing Lite (SQLite Hooks → MsgStore → SSE/WS)

**Location**: `crates/db/src/lib.rs`, `crates/services/src/services/events.rs`, `crates/utils/src/msg_store.rs`

**Flow**:
1. **SQLite Hook Registration**: `DBService::new_with_after_connect()` registers hooks on connection
2. **Change Detection**: SQLite preupdate hooks fire on INSERT/UPDATE/DELETE operations
3. **Patch Generation**: `EventService::create_hook()` generates JSON Patches for affected records
4. **MsgStore Push**: Patches pushed to in-memory `MsgStore` (broadcast channel + 100MB history buffer)
5. **SSE/WebSocket Delivery**: Frontend subscribes via `/api/events` (SSE) or `/api/events/scratch/:type/:id/stream/ws` (WebSocket)

**Key Code**:
```rust
// crates/db/src/lib.rs
pub async fn new_with_after_connect<F>(after_connect: F) -> Result<DBService, Error>
where
    F: for<'a> Fn(&'a mut SqliteConnection) -> Pin<Box<dyn Future<Output = Result<(), Error>> + Send + 'a>>
        + Send + Sync + 'static,
{
    let pool = Self::create_pool(Some(Arc::new(after_connect))).await?;
    Ok(DBService { pool })
}

// crates/services/src/services/events.rs
pub fn create_hook(
    msg_store: Arc<MsgStore>,
    entry_count: Arc<RwLock<usize>>,
    db_service: DBService,
) -> impl Fn(&mut SqliteConnection) -> Pin<...>
{
    // Hook fires on INSERT/UPDATE/DELETE
    // Generates JSON Patches
    // Pushes to MsgStore
}

// crates/utils/src/msg_store.rs
pub struct MsgStore {
    inner: RwLock<Inner>,
    sender: broadcast::Sender<LogMsg>,
}

impl MsgStore {
    pub fn push(&self, msg: LogMsg) {
        let _ = self.sender.send(msg.clone()); // live listeners
        // Also store in history (100MB buffer)
    }

    pub fn push_patch(&self, patch: json_patch::Patch) {
        self.push(LogMsg::JsonPatch(patch));
    }
}
```

**Supported Tables**: Projects, Tasks, Workspaces, Sessions, ExecutionProcesses, Scratch, Images, Tags, Merges

**Frontend Consumption**: React hooks subscribe to SSE streams, apply JSON Patches to local state using `rfc6902` library.

---

### 4. Git Worktree Isolation (Per-Workspace Worktrees)

**Location**: `crates/git/src/lib.rs`, `crates/services/src/services/workspace_service.rs`

**Problem**: Multiple parallel tasks need to work on the same repository without conflicts.

**Solution**: Each workspace gets isolated git worktrees for every repository in the project.

**Workflow**:
1. **Workspace Creation**: User creates a new workspace (formerly "task attempt")
2. **Worktree Allocation**: `WorkspaceManager` calls `WorktreeManager` for each repo in the project
3. **Directory Creation**: Worktree created at `{worktree_base}/{workspace_id}/{repo_name}`
4. **Branch Checkout**: New branch or existing branch checked out in isolation
5. **Agent Execution**: AI agent works in isolated worktree directory
6. **Merge Back**: Changes merged from worktree back to main branch when ready

**Key Operations** (GitService, 1953 lines):
- `add_worktree(repo, path, branch)` - Create new worktree
- `remove_worktree(repo, path)` - Delete worktree
- `move_worktree(repo, old_path, new_path)` - Relocate worktree
- `get_all_branches(repo)` - List branches for checkout
- `merge_changes(repo, source_branch, target_branch)` - Squash merge
- `rebase_branch(repo, branch, onto)` - Interactive rebase

**Benefits**:
- Parallel task execution without conflicts
- Clean isolation of experimental changes
- Easy cleanup (just delete worktree directory)
- Native git operations (no custom abstraction layer)

---

### 5. Executor Trait (Common Interface for 9 AI Agents)

**Location**: `crates/executors/src/lib.rs`, `crates/executors/src/executors/`

**Supported Agents** (9 implementations):
1. **ClaudeCode** - Claude Code CLI integration
2. **Amp** - Amplify executor
3. **Gemini** - Gemini CLI executor
4. **Codex** - OpenAI Codex executor
5. **Cursor** - Cursor agent executor
6. **Opencode** - OpenCode executor
7. **QwenCode** - Qwen Code executor
8. **Copilot** - GitHub Copilot executor
9. **Droid** - Droid executor

**Key Traits**:
```rust
pub trait StandardCodingAgentExecutor {
    async fn spawn(&self, ...) -> Result<ExecutorSpawnOutput>;
    async fn spawn_follow_up(&self, ...) -> Result<ExecutorSpawnOutput>;
    async fn spawn_review(&self, ...) -> Result<ExecutorSpawnOutput>;
    fn normalize_logs(&self, ...) -> impl Stream<Item = Result<LogMsg>>;
    fn available_slash_commands(&self, ...) -> Vec<SlashCommand>;
}

pub trait Executable {
    async fn spawn(&self, action: ExecutorAction) -> Result<ExecutorSpawnOutput>;
}
```

**Executor Action Types**:
- `CodingAgentInitialRequest` - Start new coding session
- `CodingAgentFollowUpRequest` - Continue existing session
- `ScriptRequest` - Run setup/cleanup scripts
- `ReviewRequest` - Review PR/code changes

**Capabilities** (feature flags per agent):
- `SessionFork` - Fork existing agent sessions
- `SetupHelper` - Assisted workspace setup
- `ContextUsage` - Context window usage tracking

**MCP Configuration**: Each agent can specify MCP (Model Context Protocol) servers to enable additional tools.

**Log Normalization**: Each executor provides `normalize_logs()` to convert agent-specific output formats to unified `LogMsg` stream.

**Approval Integration**: Agents can request permission before executing tools via the `Approvals` service.

---

## Data Architecture

### Local Database (SQLite)

**Location**: `{asset_dir}/db.sqlite`
**ORM**: SQLx with compile-time query checking
**Migrations**: 44 migrations (2025-06-17 to 2026-02-03)
**Journal Mode**: DELETE (for compatibility)

**Tables** (16 total):

| Table | Primary Key | Key Columns | Relationships |
|-------|-------------|-------------|---------------|
| **projects** | `id BLOB` | name, default_agent_working_dir, remote_project_id, created_at, updated_at | has_many tasks, has_many project_repos |
| **repos** | `id BLOB` | path (UNIQUE), name, display_name, setup_script, cleanup_script, dev_server_script, default_target_branch | has_many project_repos, has_many workspace_repos |
| **project_repos** | `id BLOB` | project_id FK, repo_id FK | Junction table (projects ↔ repos many-to-many) |
| **tasks** | `id BLOB` | project_id FK, title, description, status (CHECK), parent_workspace_id FK | belongs_to project, has_many workspaces |
| **workspaces** | `id BLOB` | task_id FK, container_ref, branch, agent_working_dir, setup_completed_at, archived, pinned, name | belongs_to task, has_many sessions, has_many workspace_repos |
| **workspace_repos** | `id BLOB` | workspace_id FK, repo_id FK, target_branch | Junction table (workspaces ↔ repos) |
| **sessions** | `id BLOB` | workspace_id FK, executor, created_at, updated_at | belongs_to workspace, has_many execution_processes |
| **execution_processes** | `id BLOB` | session_id FK, run_reason (CHECK), executor_action, status (CHECK), exit_code, dropped, started_at, completed_at | belongs_to session, has_many logs/turns/repo_states |
| **execution_process_logs** | (composite) | execution_process_id FK, data BLOB | Raw log output (append-only) |
| **execution_process_repo_states** | `id BLOB` | execution_process_id FK, repo_id FK, before_head_commit, after_head_commit, merge_commit | Tracks git state changes per-repo |
| **coding_agent_turns** | `id BLOB` | execution_process_id FK, agent_session_id, prompt, summary, seen, agent_message_id | Individual coding agent conversation turns |
| **images** | `id BLOB` | file_path, original_name, mime_type, size_bytes, hash (SHA256) | Content-addressed image storage |
| **task_images** | `id BLOB` | task_id FK, image_id FK | Junction table (tasks ↔ images) |
| **merges** | `id BLOB` | workspace_id FK, repo_id FK, merge_type (direct/pr), merge_commit, target_branch_name, pr_number, pr_url, pr_status | Tracks merges and PR merges per workspace |
| **tags** | `id BLOB` | project_id FK, name, is_default | Project tagging system |
| **scratch** | `id BLOB` | scratch_type, entity_id, payload (JSON) | General-purpose scratch pad |
| **migration_state** | `id BLOB` | organization_id, project_id, entity_type, local_id, remote_id | Tracks local↔remote migration |

**Enums**:
- `TaskStatus`: Todo, InProgress, InReview, Done, Cancelled
- `ExecutionProcessStatus`: Running, Completed, Failed, Killed
- `ExecutionProcessRunReason`: SetupScript, CodingAgent, DevServer, CleanupScript
- `MergeType`: Direct, Pr
- `ScratchType`: DraftFollowUp

**TypeScript Type Generation**: All models annotated with `#[derive(TS)]` from `ts-rs` crate, generating TypeScript definitions in `shared/types.ts`.

---

### Remote Database (PostgreSQL)

**Location**: Cloud-hosted PostgreSQL instance
**ORM**: SQLx with compile-time query checking
**Tables**: 25+ tables (organizations, issues, pull_requests, notifications, workspaces, billing, etc.)

**Key Remote-Only Tables**:
- **organizations** - Multi-tenant organization structure
- **organization_members** - User membership with roles
- **issues** - Issue tracking (linked to local tasks via migration_state)
- **issue_comments** - Threaded comments on issues
- **issue_assignees** - Issue assignment
- **issue_followers** - Issue watchers
- **issue_tags** - Issue categorization
- **issue_relationships** - Issue dependency graph
- **pull_requests** - PR tracking and review status
- **notifications** - User notification queue
- **project_statuses** - Kanban column definitions
- **sessions** - JWT session management
- **billing** - Stripe subscription tracking
- **github_app** - GitHub App installation tracking

**Electric SQL Sync**: Real-time sync to frontend via Electric SQL proxy (HTTP shape streams).

---

## API Architecture

### Local Server API (50+ Endpoints)

**Base URL**: `/api`
**Server**: Axum 0.8
**Origin Validation**: CSRF-like origin check via `VK_ALLOWED_ORIGINS` environment variable
**State**: `LocalDeployment` (implements Deployment trait)

**Endpoint Categories**:

| Category | Key Endpoints | Description |
|----------|--------------|-------------|
| **Health** | `GET /health` | Health check (no auth) |
| **Projects** | `GET/POST/PUT/DELETE /projects`, `GET/POST /projects/:id/repos` | Project CRUD, repo management |
| **Tasks** | `GET/POST/PUT/DELETE /tasks`, `GET /tasks/:id/relationships/:workspace_id` | Task CRUD, relationship queries |
| **Workspaces** | `GET/POST/PUT/DELETE /task-attempts/:id`, `POST /task-attempts/:id/{start,merge,archive,pin,rename}` | Workspace lifecycle (formerly task-attempts) |
| **Sessions** | `GET /sessions/latest/:workspace_id`, `POST /sessions`, `POST /sessions/:id/fork` | Session management, forking |
| **Execution** | `GET /execution-processes`, `POST /execution-processes/:id/kill`, `GET /execution-processes/:id/stream` (SSE) | Execution process lifecycle, streaming |
| **Containers** | `POST /container/{start,stop}`, `POST /container/send-message`, `POST /container/slash-commands` (SSE) | Agent container control |
| **Events** | `GET /events` (SSE), `GET /events/scratch/:type/:id/stream/ws` (WebSocket) | Real-time event streaming |
| **Config** | `GET/PUT /config`, `GET /config/executor-profiles`, `GET /config/login-status` | App configuration |
| **Filesystem** | `GET /filesystem/list`, `GET /filesystem/read`, `POST /filesystem/write`, `GET /filesystem/discover-repos` | File browsing, repo discovery |
| **Search** | `GET /search?q=&mode=&repo_ids=` | Code search (ripgrep-based) |
| **Tags** | `GET/POST/PUT/DELETE /tags` | Tag management |
| **Scratch** | `GET/POST/PUT/DELETE /scratch/:type/:id` | Scratch pad persistence |
| **Repos** | `GET /repos`, `GET/PUT /repos/:id` | Repository discovery, status |
| **OAuth** | `GET /oauth/status`, `POST /oauth/logout`, `GET /oauth/callback` | OAuth handoff to remote server |
| **Organizations** | `GET /organizations` | Organization listing (from remote) |
| **Approvals** | `GET /approvals/:execution_process_id`, `POST /approvals/:id/:tool_call_id` | Tool call approval queue |
| **Images** | `POST /images/upload`, `GET /images/:id` | Image upload/retrieval |
| **Terminal** | `GET /terminal/ws` (WebSocket) | PTY terminal session |
| **Migration** | `POST /migration/start` | Data migration to remote |

**SSE Endpoints**:
- `/api/events` - Real-time JSON Patch stream for all database changes
- `/api/execution-processes/:id/stream` - Execution process stdout/stderr stream
- `/api/execution-processes/:id/diff-stream` - Real-time diff statistics
- `/api/container/slash-commands` - Available slash commands for active agent

**WebSocket Endpoints**:
- `/api/events/scratch/:type/:id/stream/ws` - Scratch pad real-time updates
- `/api/terminal/ws?workspace_id=&cols=&rows=` - PTY terminal (xterm.js)

---

### Remote Server API (60+ Endpoints)

**Base URL**: `/v1`
**Server**: Axum 0.8
**Auth**: JWT session tokens, `require_session` middleware on protected routes
**CORS**: Mirror request origin with credentials

**Public Routes** (no auth required):
- `/health` - Health check
- `oauth/*` - OAuth login/callback (GitHub, Google)
- `tokens/*` - Token validation
- `review/*` - PR review submission
- `github-app/*` - GitHub App webhook handlers
- `billing/*` - Stripe webhook handlers

**Protected Routes** (JWT required):
- `identity/*` - User profile management
- `projects/*` - Project CRUD (with organization access control)
- `organizations/*` - Organization management
- `organization-members/*` - Member management
- `electric-proxy/*` - Electric SQL sync proxy
- `project-statuses/*` - Kanban column definitions
- `tags/*` - Tag management
- `issues/*` - Issue CRUD, bulk update, relationships
- `issue-comments/*` - Comment threads
- `issue-assignees/*` - Assignment management
- `issue-followers/*` - Watcher management
- `issue-tags/*` - Issue categorization
- `issue-relationships/*` - Dependency graph
- `pull-requests/*` - PR review pipeline
- `notifications/*` - Notification queue
- `workspaces/*` - Remote workspace tracking
- `billing/*` - Subscription management
- `migration/*` - Data migration endpoints

**Authorization**: `ensure_project_access()` checks organization membership for project operations.

---

## Frontend Architecture

### Container/View Pattern

**Location**: `frontend/src/components/ui-new/`

**Principle**: Separate data-fetching containers from stateless view components.

**Structure**:
```
components/ui-new/
├── containers/          # Data containers (hooks, queries, state)
│   ├── ProjectContainer.tsx
│   ├── TaskContainer.tsx
│   └── WorkspaceContainer.tsx
├── views/              # Stateless view components (props only)
│   ├── ProjectView.tsx
│   ├── TaskView.tsx
│   └── WorkspaceView.tsx
├── primitives/         # Base UI primitives (Button, Input, etc.)
└── dialogs/            # Dialog wrappers
```

**Example**:
```tsx
// Container (in containers/)
export function TaskContainer({ taskId }: { taskId: string }) {
  const { task, loading, error } = useTask(taskId);
  const { updateTask } = useTaskMutations();

  if (loading) return <Spinner />;
  if (error) return <ErrorView error={error} />;

  return (
    <TaskView
      task={task}
      onUpdate={updateTask}
    />
  );
}

// View (in views/)
export function TaskView({ task, onUpdate }: TaskViewProps) {
  return (
    <div className="task-view">
      <h1>{task.title}</h1>
      <p>{task.description}</p>
      <Button onClick={() => onUpdate({ status: 'Done' })}>
        Complete
      </Button>
    </div>
  );
}
```

**Benefits**: Easier testing, clearer separation of concerns, reusable views.

---

### Zustand Stores (5 Global Stores)

**Location**: `frontend/src/stores/`

| Store | File | Responsibility |
|-------|------|---------------|
| **AppStore** | `useAppStore.ts` | Global app state (sidebar visibility, active panel, theme) |
| **ProjectStore** | `useProjectStore.ts` | Active project, project list |
| **TaskStore** | `useTaskStore.ts` | Active task, task list, filters |
| **ExecutionStore** | `useExecutionStore.ts` | Active execution processes, logs |
| **SettingsStore** | `useSettingsStore.ts` | User settings (editor, notifications, etc.) |

**Pattern**: Zustand stores used for cross-component state that doesn't fit in React Context.

---

### React Context (25 Providers)

**Location**: `frontend/src/contexts/`

**Key Contexts**:
- `ProjectContext` - Active project state
- `TaskContext` - Active task state
- `WorkspaceContext` - Active workspace state
- `ExecutionProcessContext` - Active execution process state
- `DiffContext` - Diff viewer state
- `AuthContext` - Authentication state
- `RemoteContext` - Remote server connection state

**Pattern**: React Context used for scoped component state (e.g., task detail page).

---

### Electric SQL Integration

**Location**: `frontend/src/lib/electric/`

**Purpose**: Real-time sync from remote PostgreSQL to frontend via HTTP shape streams.

**Dependencies**:
- `@tanstack/electric-db-collection` - Electric SQL client
- `@tanstack/react-db` - React integration
- `wa-sqlite` - WASM SQLite for local caching

**Usage**:
```tsx
import { useDbCollection } from '@tanstack/react-db';

function IssueList() {
  const issues = useDbCollection({
    queryKey: ['issues', projectId],
    shape: {
      url: `/v1/electric-proxy/issues`,
      params: { project_id: projectId }
    }
  });

  return <IssueListView issues={issues} />;
}
```

**Benefits**: Automatic sync, offline support, optimistic updates.

---

## Authentication & Security

### Local Server Authentication

**Origin Validation** (CSRF-like protection):
```rust
// crates/server/src/middleware/origin.rs
async fn validate_origin(request: Request<Body>) -> Result<Request<Body>, StatusCode> {
    let allowed_origins = env::var("VK_ALLOWED_ORIGINS")
        .unwrap_or_default()
        .split(',')
        .map(|s| s.trim())
        .collect::<Vec<_>>();

    let origin = request.headers().get(ORIGIN)
        .and_then(|v| v.to_str().ok());

    match origin {
        Some("null") => Err(StatusCode::FORBIDDEN), // Explicit null rejection
        Some(origin) if allowed_origins.contains(&origin) => Ok(request),
        _ => Err(StatusCode::FORBIDDEN)
    }
}
```

**OAuth Flow** (delegated to remote server):
1. User clicks "Login with GitHub" in local app
2. Local server redirects to remote server OAuth endpoint
3. Remote server handles GitHub/Google OAuth PKCE flow
4. Remote server issues JWT token
5. Remote server redirects back to local server with token
6. Local server stores JWT in `OAuthCredentials` (disk persistence)
7. Local server refreshes token automatically when expired

**Credential Storage**:
```rust
// crates/services/src/services/oauth_credentials.rs
pub struct OAuthCredentials {
    pub access_token: String,
    pub refresh_token: String,
    pub expires_at: DateTime<Utc>,
}

impl OAuthCredentials {
    pub async fn load() -> Result<Self>;
    pub async fn save(&self) -> Result<()>;
    pub fn expires_soon(&self) -> bool;
}
```

---

### Remote Server Authentication

**JWT Authentication**:
```rust
// crates/remote/src/auth/jwt.rs
pub struct JwtService {
    encoding_key: EncodingKey,
    decoding_key: DecodingKey,
}

impl JwtService {
    pub fn create_token(&self, user_id: Uuid, organization_id: Uuid) -> Result<String>;
    pub fn verify_token(&self, token: &str) -> Result<Claims>;
}
```

**OAuth Providers**:
- **GitHub OAuth** - Authorization code flow with PKCE
- **Google OAuth** - Authorization code flow with PKCE

**Session Management**:
- Sessions stored in PostgreSQL `sessions` table
- JWT tokens encrypted at rest using AES-256-GCM
- Automatic token refresh via refresh tokens

**Authorization**:
```rust
// crates/remote/src/middleware/auth.rs
async fn ensure_project_access(
    user_id: Uuid,
    project_id: Uuid,
    pool: &PgPool
) -> Result<(), AuthError> {
    // Check if user is member of organization that owns project
    let is_member = sqlx::query_scalar!(
        "SELECT EXISTS(SELECT 1 FROM organization_members om
         JOIN projects p ON p.organization_id = om.organization_id
         WHERE om.user_id = $1 AND p.id = $2)",
        user_id, project_id
    ).fetch_one(pool).await?;

    if !is_member {
        return Err(AuthError::Forbidden);
    }

    Ok(())
}
```

---

### Executor Approvals

**Purpose**: Allow users to approve/reject tool calls made by AI agents before execution.

**Flow**:
1. AI agent requests to execute a tool (e.g., "delete file X")
2. Agent pauses and sends approval request to backend
3. Backend stores request in `Approvals` service (DashMap)
4. Frontend polls `/api/approvals/:execution_process_id` or receives SSE event
5. User approves or rejects via `POST /api/approvals/:execution_process_id/:tool_call_id`
6. Backend sends response to agent via oneshot channel
7. Agent resumes execution based on approval

**Implementation**:
```rust
// crates/services/src/services/approvals.rs
pub struct Approvals {
    pending: Arc<DashMap<String, PendingApproval>>,
}

pub struct PendingApproval {
    pub tool_name: String,
    pub arguments: serde_json::Value,
    pub sender: oneshot::Sender<ApprovalResponse>,
}

impl Approvals {
    pub async fn request_approval(
        &self,
        execution_process_id: Uuid,
        tool_call_id: String,
        tool_name: String,
        arguments: serde_json::Value,
    ) -> Result<ApprovalResponse> {
        let (tx, rx) = oneshot::channel();
        self.pending.insert(
            format!("{execution_process_id}:{tool_call_id}"),
            PendingApproval { tool_name, arguments, sender: tx }
        );
        rx.await
    }
}
```

---

## Real-time Communication

### Server-Sent Events (SSE)

**Endpoints**:
1. `/api/events` - Global event stream (JSON Patches for all database changes)
2. `/api/execution-processes/:id/stream` - Execution process stdout/stderr
3. `/api/execution-processes/:id/diff-stream` - Real-time diff statistics
4. `/api/container/slash-commands` - Available slash commands

**Implementation**:
```rust
// crates/server/src/routes/events.rs
async fn events_stream(
    State(deployment): State<LocalDeployment>,
) -> Sse<impl Stream<Item = Result<Event, std::io::Error>>> {
    let stream = deployment.stream_events().await;
    Sse::new(stream)
}
```

**Frontend Consumption**:
```tsx
import { useEffect } from 'react';

function useEventStream() {
  useEffect(() => {
    const eventSource = new EventSource('/api/events');

    eventSource.onmessage = (event) => {
      const patch = JSON.parse(event.data);
      applyPatch(localState, patch); // rfc6902
    };

    return () => eventSource.close();
  }, []);
}
```

---

### WebSocket Communication

**Endpoints**:
1. `/api/events/scratch/:type/:id/stream/ws` - Scratch pad real-time updates
2. `/api/terminal/ws?workspace_id=&cols=&rows=` - PTY terminal (xterm.js)

**Implementation**:
```rust
// crates/server/src/routes/terminal.rs
async fn terminal_ws(
    ws: WebSocketUpgrade,
    Query(params): Query<TerminalParams>,
    State(deployment): State<LocalDeployment>,
) -> impl IntoResponse {
    ws.on_upgrade(|socket| handle_terminal(socket, params, deployment))
}

async fn handle_terminal(
    socket: WebSocket,
    params: TerminalParams,
    deployment: LocalDeployment,
) {
    let pty = deployment.pty().spawn_pty(...).await;

    // Bidirectional stream: socket ↔ PTY
    tokio::spawn(async move {
        loop {
            tokio::select! {
                Some(msg) = socket.recv() => {
                    pty.write(msg).await;
                }
                Some(data) = pty.read() => {
                    socket.send(data).await;
                }
            }
        }
    });
}
```

**Frontend Consumption** (xterm.js):
```tsx
import { Terminal } from '@xterm/xterm';
import { useWebSocket } from 'react-use-websocket';

function TerminalView({ workspaceId }: { workspaceId: string }) {
  const terminal = new Terminal();
  const { sendMessage, lastMessage } = useWebSocket(
    `/api/terminal/ws?workspace_id=${workspaceId}&cols=80&rows=24`
  );

  useEffect(() => {
    terminal.onData((data) => sendMessage(data));
  }, [terminal]);

  useEffect(() => {
    if (lastMessage) {
      terminal.write(lastMessage.data);
    }
  }, [lastMessage]);

  return <div ref={(el) => terminal.open(el)} />;
}
```

---

### JSON Patch Protocol

**Format**: RFC 6902 JSON Patch

**Example Event**:
```json
{
  "op": "replace",
  "path": "/tasks/550e8400-e29b-41d4-a716-446655440000",
  "value": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Implement authentication",
    "status": "InProgress",
    "updated_at": "2026-02-17T12:34:56Z"
  }
}
```

**Frontend Application**:
```tsx
import { applyPatch } from 'rfc6902';

function applyEventPatch(state: AppState, patch: Patch) {
  applyPatch(state, patch);
  // Re-render components subscribed to affected state
}
```

---

### MsgStore Architecture

**Location**: `crates/utils/src/msg_store.rs`

**Purpose**: In-memory pub/sub for real-time event distribution with history buffer.

**Structure**:
```rust
pub struct MsgStore {
    inner: RwLock<Inner>,
    sender: broadcast::Sender<LogMsg>,
}

struct Inner {
    history: VecDeque<StoredMsg>,
    total_bytes: usize,
}
```

**Key Features**:
- **Broadcast Channel**: 10,000 message capacity
- **History Buffer**: 100MB total (FIFO eviction)
- **Message Types**: Stdout, Stderr, JsonPatch, SessionId, MessageId, Finished
- **Subscribers**: Each SSE client gets a receiver via `sender.subscribe()`
- **History Replay**: New subscribers get full history + live stream via `history_plus_stream()`

**Usage**:
```rust
// Push message
msg_store.push(LogMsg::JsonPatch(patch));

// Subscribe
let receiver = msg_store.get_receiver();
let stream = BroadcastStream::new(receiver);

// History + live
let stream = msg_store.history_plus_stream();
```

---

## Build & Distribution

### Build Process

**Local Build Script**: `build-vibe-kanban.sh`

**Steps**:
1. **Generate TypeScript Types**: `cargo run --bin generate_types`
2. **Build Frontend**: `cd frontend && pnpm run build`
3. **Embed Frontend**: Frontend dist embedded into Rust binary via `rust-embed`
4. **Build Rust Binary**: `cargo build --release`
5. **Platform Binaries**: 6-platform cross-compilation via GitHub Actions

**rust-embed Integration**:
```rust
// crates/server/src/lib.rs
use rust_embed::RustEmbed;

#[derive(RustEmbed)]
#[folder = "../frontend/dist"]
struct FrontendAssets;

// Serve embedded files at /
async fn serve_frontend() -> impl IntoResponse {
    let file = FrontendAssets::get("index.html").unwrap();
    Html(file.data)
}
```

---

### Cross-Platform Compilation

**GitHub Actions Workflow**: `.github/workflows/pre-release.yml`

**Build Matrix** (6 platforms):
1. **macOS Intel** (x86_64-apple-darwin)
2. **macOS ARM** (aarch64-apple-darwin)
3. **Linux x64** (x86_64-unknown-linux-gnu)
4. **Linux ARM64** (aarch64-unknown-linux-gnu)
5. **Windows x64** (x86_64-pc-windows-msvc)
6. **Windows ARM64** (aarch64-pc-windows-msvc)

**macOS Signing**:
- Apple Developer ID certificate
- Code signing via `codesign`
- Notarization via `xcrun notarytool`

**Distribution**:
- Binaries uploaded to Cloudflare R2
- npx wrapper downloads platform-specific binary on first run
- Cached in `~/.vibe-kanban/bin/`

---

### NPX Distribution Wrapper

**Location**: `npx-cli/`

**Package Name**: `vibe-kanban` (on npm)

**Entry Point**: `npx-cli/bin/cli.js`

**Flow**:
1. User runs `npx vibe-kanban`
2. npm downloads `vibe-kanban` package (if not cached)
3. `cli.js` detects platform (os, arch)
4. `download.js` fetches platform binary from Cloudflare R2 (if not cached)
5. Binary cached to `~/.vibe-kanban/bin/vibe-kanban-{platform}-{arch}`
6. Execute binary with user args

**Platform Detection**:
```javascript
// npx-cli/bin/cli.js
const platform = process.platform; // darwin, linux, win32
const arch = process.arch; // x64, arm64

const binaryName = `vibe-kanban-${platform}-${arch}${platform === 'win32' ? '.exe' : ''}`;
```

---

## Glossary

| Term | Definition |
|------|-----------|
| **Workspace** | Isolated environment for a task (formerly "task attempt"), with dedicated git worktrees |
| **Executor** | AI coding agent implementation (Claude, Gemini, etc.) |
| **Deployment** | Abstract trait for service access (LocalDeployment for desktop) |
| **MsgStore** | In-memory pub/sub for real-time events with history buffer |
| **Worktree** | Git worktree - isolated working directory sharing .git objects |
| **Session** | Coding agent session within a workspace |
| **ExecutionProcess** | Single agent execution run (setup script, coding agent, dev server, cleanup) |
| **SSE** | Server-Sent Events - unidirectional real-time streaming |
| **WebSocket** | Bidirectional real-time communication (terminals, scratch) |
| **JSON Patch** | RFC 6902 format for incremental state updates |
| **Electric SQL** | Real-time PostgreSQL sync via HTTP shape streams |
| **Container** | Workspace lifecycle management service (not Docker) |
| **Scratch** | Temporary draft storage (follow-ups, notes) |
| **Approval** | User permission for agent tool execution |

---

*Generated by BMAD Document Project Workflow v1.2.0 (Deep Scan)*
