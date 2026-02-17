# BMAD Vibe Kanban - API Contracts Reference

## Overview

BMAD Vibe Kanban provides two distinct API surfaces:

1. **Local Server API** - Desktop application server (Axum + SQLite) for local-first task management
2. **Remote Server API** - Optional cloud server (Axum + PostgreSQL) for team collaboration and sync

Both servers use Axum web framework with REST-style endpoints, SSE for streaming, and WebSocket for bidirectional communication.

## API Architecture

### Base URLs

| Server | Base URL | Frontend Served At |
|--------|----------|-------------------|
| **Local** | `/api` | `/` (static files) |
| **Remote** | `/v1` | N/A (API only) |

### Authentication Patterns

| Server | Authentication | CSRF/CORS |
|--------|---------------|-----------|
| **Local** | None (localhost only) | Origin header validation via `VK_ALLOWED_ORIGINS` |
| **Remote** | JWT Bearer tokens | Mirror request CORS with credentials |

### Response Format

All endpoints return JSON with this general structure:

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
}
```

## Local Server Endpoints (50+)

**Server Type:** Axum-based local desktop server
**Database:** SQLite with event hooks
**State Type:** `LocalDeployment` (implements `Deployment` trait)
**Origin Validation:** CSRF-like origin check via `VK_ALLOWED_ORIGINS` environment variable

### Health

| Method | Path | Handler | Auth | Description |
|--------|------|---------|------|-------------|
| GET | `/api/health` | `health::health_check` | None | Health check endpoint |

### Projects

Projects are the top-level organizational unit containing tasks and repositories.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/projects` | `projects::list_projects` | List all projects (returns `Vec<Project>`) |
| POST | `/api/projects` | `projects::create_project` | Create project (request: `CreateProject`) |
| GET | `/api/projects/:project_id` | `projects::get_project` | Get project details (middleware: `load_project_middleware`) |
| PUT | `/api/projects/:project_id` | `projects::update_project` | Update project (request: `UpdateProject`) |
| DELETE | `/api/projects/:project_id` | `projects::delete_project` | Delete project |
| GET | `/api/projects/:project_id/auto-setup` | `projects::project_auto_setup` | Auto-discover and setup repositories |

**Project Repositories:**

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/projects/:project_id/repos` | `projects::get_project_repos` | List repositories in project |
| POST | `/api/projects/:project_id/repos` | `projects::add_repo_to_project` | Add repository to project |
| PUT | `/api/projects/:project_id/repos/:project_repo_id` | `projects::update_project_repo` | Update project-repo association |
| DELETE | `/api/projects/:project_id/repos/:project_repo_id` | `projects::remove_repo_from_project` | Remove repository from project |

### Tasks

Tasks represent work items within projects.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/tasks` | `tasks::list_tasks_by_project` | List tasks (query: `project_id`) |
| POST | `/api/tasks` | `tasks::create_task` | Create task (request: `CreateTask`) |
| GET | `/api/tasks/:task_id` | `tasks::get_task` | Get task details (middleware: `load_task_middleware`) |
| PUT | `/api/tasks/:task_id` | `tasks::update_task` | Update task (request: `UpdateTask`) |
| DELETE | `/api/tasks/:task_id` | `tasks::delete_task` | Delete task |
| GET | `/api/tasks/:task_id/relationships/:workspace_id` | `tasks::get_task_relationships` | Get parent-child task relationships |

**Task Statuses:**
- `todo` - Not started
- `inprogress` - In progress
- `inreview` - In review
- `done` - Completed
- `cancelled` - Cancelled

### Workspaces (Task Attempts)

Workspaces are isolated environments for executing tasks with git worktrees.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/task-attempts` | `task_attempts::list_task_attempts` | List workspaces (query: `task_id`) |
| POST | `/api/task-attempts` | `task_attempts::create_task_attempt` | Create workspace |
| GET | `/api/task-attempts/:workspace_id` | `task_attempts::get_task_attempt` | Get workspace details (middleware: `load_workspace_middleware`) |
| PUT | `/api/task-attempts/:workspace_id` | `task_attempts::update_task_attempt` | Update workspace |
| DELETE | `/api/task-attempts/:workspace_id` | `task_attempts::delete_task_attempt` | Delete workspace |

**Workspace Actions:**

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/api/task-attempts/:workspace_id/start` | `task_attempts::start_task_attempt` | Start workspace (run setup, spawn agent) |
| POST | `/api/task-attempts/:workspace_id/follow-up` | `task_attempts::follow_up_task_attempt` | Send follow-up message to agent |
| POST | `/api/task-attempts/:workspace_id/review` | `task_attempts::review_task_attempt` | Request code review |
| POST | `/api/task-attempts/:workspace_id/create-pr` | `task_attempts::create_pr` | Create pull request |
| POST | `/api/task-attempts/:workspace_id/merge` | `task_attempts::merge` | Direct merge to target branch |
| POST | `/api/task-attempts/:workspace_id/merge-branch` | `task_attempts::merge_branch` | Merge branch operation |
| POST | `/api/task-attempts/:workspace_id/merge-squash` | `task_attempts::merge_squash` | Squash merge to target branch |
| POST | `/api/task-attempts/:workspace_id/rebase` | `task_attempts::rebase` | Rebase workspace branch |
| POST | `/api/task-attempts/:workspace_id/archive` | `task_attempts::archive` | Archive workspace |
| POST | `/api/task-attempts/:workspace_id/unarchive` | `task_attempts::unarchive` | Unarchive workspace |
| POST | `/api/task-attempts/:workspace_id/pin` | `task_attempts::pin` | Pin workspace |
| POST | `/api/task-attempts/:workspace_id/unpin` | `task_attempts::unpin` | Unpin workspace |
| POST | `/api/task-attempts/:workspace_id/rename` | `task_attempts::rename` | Rename workspace |

### Sessions

Sessions represent agent execution instances within workspaces.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/sessions/latest/:workspace_id` | `sessions::get_latest_session` | Get most recent session for workspace |
| POST | `/api/sessions` | `sessions::create_session` | Create new session |
| POST | `/api/sessions/:session_id/fork` | `sessions::fork_session` | Fork session with new context |

### Execution Processes

Execution processes track running tasks (setup scripts, coding agents, dev servers, cleanup scripts).

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/execution-processes` | `execution_processes::list` | List processes (query: `session_id`) |
| GET | `/api/execution-processes/:execution_process_id` | `execution_processes::get` | Get process details |
| POST | `/api/execution-processes/:execution_process_id/kill` | `execution_processes::kill` | Kill running process |
| GET | `/api/execution-processes/:execution_process_id/stream` | `execution_processes::stream` | **SSE** - Stream process logs |
| GET | `/api/execution-processes/:execution_process_id/diff-stream` | `execution_processes::diff_stream` | **SSE** - Stream git diff statistics |

**Execution Process Run Reasons:**
- `setupscript` - Setup script execution
- `codingagent` - Coding agent session
- `devserver` - Development server
- `cleanupscript` - Cleanup script execution

**Execution Process Statuses:**
- `running` - Currently executing
- `completed` - Successfully completed
- `failed` - Failed with error
- `killed` - Terminated by user

### Containers

Container operations manage workspace lifecycle and agent communication.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/api/container/start` | `containers::start_container` | Start workspace container |
| POST | `/api/container/stop` | `containers::stop_container` | Stop workspace container |
| POST | `/api/container/slash-commands` | `containers::get_slash_commands` | **SSE** - Get available slash commands |
| POST | `/api/container/send-message` | `containers::send_message` | Send message to running agent |

### Events

Real-time event streaming for UI updates.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/events` | `events::events_stream` | **SSE** - Stream all database events (JSON Patch format) |
| GET | `/api/events/scratch/:scratch_type/:id/stream/ws` | `events::scratch` | **WebSocket** - Stream scratch pad updates |

### Configuration

Application configuration management.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/config` | `config::get_config` | Get current configuration (v8 schema) |
| PUT | `/api/config` | `config::update_config` | Update configuration |
| GET | `/api/config/executor-profiles` | `config::get_executor_profiles` | Get available executor profiles |
| GET | `/api/config/login-status` | `config::get_login_status` | Get OAuth login status |

**Config Schema (v8):**
- `notifications` - Sound and push notification settings
- `editor` - Editor type (VSCode, Cursor, Windsurf, Zed, etc.)
- `theme` - Theme mode (light/dark/auto)
- `github` - GitHub configuration
- `language` - UI language
- `send_message_shortcut` - Keyboard shortcut configuration
- `showcase_state` - Showcase state
- `pr_description_prompt` - Customizable PR description template
- `commit_reminder_prompt` - Customizable commit reminder

### Filesystem

File system operations for repository browsing and editing.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/filesystem/list` | `filesystem::list_directory` | List directory contents |
| GET | `/api/filesystem/read` | `filesystem::read_file` | Read file contents |
| POST | `/api/filesystem/write` | `filesystem::write_file` | Write file contents |
| GET | `/api/filesystem/discover-repos` | `filesystem::discover_repos` | Discover git repositories from path |

### Search

File and content search across repositories.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/search` | `search::search_files` | Search files (query: `q`, `mode`, `repo_ids`) |

**Search Modes:**
- File name search with git history ranking
- Content search (future)

### Tags

Project-level tags for organizing tasks.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/tags` | `tags::list_tags` | List all tags |
| POST | `/api/tags` | `tags::create_tag` | Create tag |
| PUT | `/api/tags/:tag_id` | `tags::update_tag` | Update tag |
| DELETE | `/api/tags/:tag_id` | `tags::delete_tag` | Delete tag |

### Scratch

General-purpose scratch pad for notes and drafts.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/scratch` | `scratch::list_scratch` | List scratch entries |
| GET | `/api/scratch/:scratch_type/:id` | `scratch::get_scratch` | Get scratch entry |
| POST | `/api/scratch/:scratch_type/:id` | `scratch::create_scratch` | Create scratch entry |
| PUT | `/api/scratch/:scratch_type/:id` | `scratch::update_scratch` | Update scratch entry |
| DELETE | `/api/scratch/:scratch_type/:id` | `scratch::delete_scratch` | Delete scratch entry |
| GET | `/api/scratch/:scratch_type/:id/stream/ws` | `scratch::stream_scratch_ws` | **WebSocket** - Stream scratch updates |

**Scratch Types:**
- `DraftFollowUp` - Draft follow-up messages

### Repositories

Repository management and configuration.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/repos` | `repo::list_repos` | List all repositories |
| GET | `/api/repos/:repo_id` | `repo::get_repo` | Get repository details |
| PUT | `/api/repos/:repo_id` | `repo::update_repo` | Update repository (setup/cleanup/dev scripts) |

**Repository Scripts:**
- `setup_script` - Run before agent starts
- `cleanup_script` - Run when workspace teardown
- `dev_server_script` - Start development server
- `archive_script` - Archive workspace
- `copy_files` - Files to copy to workspace

### OAuth

OAuth authentication flow management.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/oauth/status` | `oauth::status` | Get OAuth status and user profile |
| POST | `/api/oauth/logout` | `oauth::logout` | Logout and clear credentials |
| GET | `/api/oauth/callback` | `oauth::callback` | OAuth callback handler (authorization code exchange) |

**OAuth Providers (via remote server):**
- GitHub
- Google

### Organizations

Organization listing for remote sync.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/organizations` | `organizations::list_organizations` | List organizations user has access to |

### Approvals

Tool call approval system for agent safety.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/approvals/:execution_process_id` | `approvals::list_approvals` | List pending approvals |
| POST | `/api/approvals/:execution_process_id/:tool_call_id` | `approvals::respond_to_approval` | Approve or reject tool call |

**Approval States:**
- `pending` - Awaiting user decision
- `approved` - User approved
- `rejected` - User rejected

### Images

Image upload and storage with content-addressed deduplication.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/api/images/upload` | `images::upload_image` | Upload image (multipart form) |
| GET | `/api/images/:image_id` | `images::get_image` | Get image by ID |

**Image Storage:**
- SHA256 hash-based deduplication
- MIME type detection
- Original filename preservation
- Size tracking in bytes

### Terminal

Browser-based terminal emulator via xterm.js.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/terminal/ws` | `terminal::terminal_ws` | **WebSocket** - PTY session (query: `workspace_id`, `cols`, `rows`) |

### Migration

Data migration between local and remote servers.

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/api/migration/start` | `migration::start_migration` | Start migration from local to remote |

## Remote Server Endpoints (60+)

**Server Type:** Axum-based cloud server
**Database:** PostgreSQL
**Authentication:** JWT session tokens with `require_session` middleware
**Authorization:** Organization membership checks via `ensure_project_access()`
**CORS:** Mirror request CORS with credentials

### Public Routes (No Authentication Required)

| Domain | Endpoints |
|--------|-----------|
| **Health** | `/health` |
| **OAuth** | `oauth/*` |
| **Organization Members** | `organization-members/*` (partial) |
| **Tokens** | `tokens/*` |
| **Review** | `review/*` - PR review submission endpoint |
| **GitHub App** | `github-app/*` (webhooks) |
| **Billing** | `billing/*` (webhooks) |

### Protected Routes (JWT Authentication Required)

#### Identity

| Endpoint Group | Description |
|---------------|-------------|
| `identity/*` | User identity and profile management |

#### Projects

| Endpoint Group | Description |
|---------------|-------------|
| `projects/*` | Project CRUD operations |
| `project-statuses/*` | Project status management |

#### Issues

Issues are the remote equivalent of local tasks, with enhanced collaboration features.

| Endpoint Group | Description |
|---------------|-------------|
| `issues/*` | Issue CRUD + bulk update operations |
| `issue-comments/*` | Comment threads on issues |
| `issue-comment-reactions/*` | Reactions to comments |
| `issue-assignees/*` | Issue assignment management |
| `issue-followers/*` | Issue follower/subscriber management |
| `issue-tags/*` | Tag associations for issues |
| `issue-relationships/*` | Parent-child and related issue links |

#### Organizations

| Endpoint Group | Description |
|---------------|-------------|
| `organizations/*` | Organization CRUD and settings |
| `organization-members/*` | Member management and invitations |

#### Pull Requests

| Endpoint Group | Description |
|---------------|-------------|
| `pull-requests/*` | PR tracking and status management |

#### Workspaces

| Endpoint Group | Description |
|---------------|-------------|
| `workspaces/*` | Remote workspace sync and management |

#### Notifications

| Endpoint Group | Description |
|---------------|-------------|
| `notifications/*` | User notification management |

#### OAuth

| Endpoint Group | Description |
|---------------|-------------|
| `oauth/*` | OAuth provider configuration (protected endpoints) |

#### Integrations

| Endpoint Group | Description |
|---------------|-------------|
| `electric-proxy/*` | Electric SQL real-time sync proxy |
| `github-app/*` | GitHub App installation management |

#### Billing

| Endpoint Group | Description |
|---------------|-------------|
| `billing/*` | Subscription and billing management |

#### Migration

| Endpoint Group | Description |
|---------------|-------------|
| `migration/*` | Data migration coordination |

## SSE (Server-Sent Events) Endpoints

SSE endpoints provide one-way streaming from server to client.

### Local Server SSE

| Path | Description | Event Types |
|------|-------------|-------------|
| `/api/events` | Database change events | JSON Patch arrays for entity updates |
| `/api/execution-processes/:id/stream` | Process log output | `stdout`, `stderr`, `system` messages |
| `/api/execution-processes/:id/diff-stream` | Git diff statistics | Real-time diff stats (additions, deletions) |
| `/api/container/slash-commands` | Available slash commands | Command list for current agent |

**Event Format (Database Events):**
```typescript
interface EventMessage {
  data: JSONPatch[]  // RFC 6902 JSON Patch operations
}
```

**Event Format (Process Logs):**
```typescript
interface LogMessage {
  stream: 'stdout' | 'stderr' | 'system'
  data: string
  timestamp: string
}
```

## WebSocket Endpoints

WebSocket endpoints provide bidirectional communication.

### Local Server WebSocket

| Path | Description | Message Format |
|------|-------------|---------------|
| `/api/terminal/ws` | PTY terminal session | Binary (terminal escape sequences) |
| `/api/scratch/:scratch_type/:id/stream/ws` | Scratch pad updates | JSON (scratch content) |
| `/api/events/scratch/:scratch_type/:id/stream/ws` | Alternative scratch endpoint | JSON (scratch content) |

**Terminal WebSocket:**
- Query parameters: `workspace_id`, `cols`, `rows`
- Bidirectional: Client sends keystrokes, server sends terminal output
- Uses xterm.js on frontend

**Scratch WebSocket:**
- Real-time collaborative editing (future)
- Current: One-way updates from server

## Authentication Details

### Local Server - Origin Validation

**Mechanism:** CSRF-like origin header validation

**Configuration:**
```bash
VK_ALLOWED_ORIGINS="http://localhost:3000,http://localhost:5173"
```

**Behavior:**
- Validates `Origin` and `Referer` headers
- Normalizes loopback addresses (127.0.0.1, localhost, ::1)
- Rejects null origin
- Returns 403 on validation failure

**Middleware:** `validate_origin()` in `server/middleware/origin.rs`

### Remote Server - JWT Authentication

**Mechanism:** JWT Bearer tokens in `Authorization` header

**Flow:**
1. User logs in via OAuth provider (GitHub/Google)
2. Remote server issues JWT session token
3. Token includes user ID, organization access
4. Local client stores token via `OAuthCredentials`
5. Token auto-refreshes when `expires_soon()` returns true

**Authorization:**
- `require_session` middleware extracts and validates JWT
- `ensure_project_access()` checks organization membership
- Rejected requests return 401 (unauthenticated) or 403 (unauthorized)

## Error Response Format

All errors follow this structure:

```typescript
interface ErrorResponse {
  success: false
  error: string  // User-friendly error message
}
```

**Common HTTP Status Codes:**
- `200 OK` - Success
- `201 Created` - Resource created
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Permission denied
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

## Rate Limiting

**Local Server:** No rate limiting (localhost only)

**Remote Server:** Rate limiting implemented at infrastructure level (not in application code)

## Pagination

**Current:** No pagination (returns all results)

**Future:** Cursor-based pagination planned for:
- `/api/tasks` (when project has 100+ tasks)
- `/api/execution-processes` (when session has many processes)
- Issue endpoints on remote server

## Versioning

**Local Server:** No versioning (single binary, always latest)

**Remote Server:** Version prefix `/v1` allows future breaking changes via `/v2`

**Type Safety:** Rust types with ts-rs ensure frontend-backend contract consistency

## Monitoring and Observability

### Analytics

**Provider:** PostHog
**Events Tracked:**
- `session_start` - Application startup
- Task creation, completion, cancellation
- Workspace operations (start, merge, archive)
- PR creation and merge events
- Agent executor selection

**Configuration:**
```bash
POSTHOG_API_KEY=your_key
POSTHOG_API_ENDPOINT=https://app.posthog.com
```

### Error Monitoring

**Provider:** Sentry
**Scope:** Both frontend and backend
**Data Collected:**
- Uncaught exceptions
- Panic stack traces (Rust)
- User context (user_id, session_id)
- Breadcrumbs (recent events)

### Logging

**Backend:** `tracing` with `RUST_LOG` environment variable
**Levels:** error, warn, info, debug, trace
**Default:** `RUST_LOG=info`

---

*Generated by BMAD Document Project Workflow v1.2.0 (Deep Scan)*
