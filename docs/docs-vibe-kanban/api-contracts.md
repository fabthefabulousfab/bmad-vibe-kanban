# Vibe Kanban - API Contracts

> REST API endpoint documentation

## API Overview

All API endpoints are prefixed with `/api` and protected by origin validation middleware.

**Base URL:** `http://localhost:{BACKEND_PORT}/api`

## Route Modules

### Health & Status

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Health check endpoint |

### Projects

**Module:** `crates/server/src/routes/projects.rs` (19,753 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/projects` | GET | List all projects |
| `/api/projects` | POST | Create new project |
| `/api/projects/:id` | GET | Get project by ID |
| `/api/projects/:id` | PUT | Update project |
| `/api/projects/:id` | DELETE | Delete project |

### Tasks

**Module:** `crates/server/src/routes/tasks.rs` (13,219 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/tasks` | GET | List tasks (filtered by project) |
| `/api/tasks` | POST | Create new task |
| `/api/tasks/:id` | GET | Get task by ID |
| `/api/tasks/:id` | PUT | Update task |
| `/api/tasks/:id` | DELETE | Delete task |

### Task Attempts (Workspaces)

**Module:** `crates/server/src/routes/task_attempts.rs` (57,503 bytes - largest route file)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/workspaces` | GET | List workspaces |
| `/api/workspaces` | POST | Create workspace (git worktree) |
| `/api/workspaces/:id` | GET | Get workspace details |
| `/api/workspaces/:id` | DELETE | Delete workspace |
| `/api/workspaces/:id/diff` | GET | Get git diff for workspace |
| `/api/workspaces/:id/sessions` | POST | Start agent session |
| `/api/workspaces/:id/pr` | POST | Create pull request |

### Sessions

**Module:** `crates/server/src/routes/sessions/`

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/sessions/:id` | GET | Get session details |
| `/api/sessions/:id/message` | POST | Send message to agent |
| `/api/sessions/:id/stop` | POST | Stop agent session |

### Execution Processes

**Module:** `crates/server/src/routes/execution_processes.rs` (8,925 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/execution-processes` | GET | List running processes |
| `/api/execution-processes/:id` | GET | Get process details |
| `/api/execution-processes/:id/logs` | GET | Get process output logs |
| `/api/execution-processes/:id/stop` | POST | Stop process |

### Tags

**Module:** `crates/server/src/routes/tags.rs` (2,954 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/tags` | GET | List all tags |
| `/api/tags` | POST | Create tag |
| `/api/tags/:id` | PUT | Update tag |
| `/api/tags/:id` | DELETE | Delete tag |

### Configuration

**Module:** `crates/server/src/routes/config.rs` (18,554 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/settings` | GET | Get application settings |
| `/api/settings` | PUT | Update settings |
| `/api/executors` | GET | List available executors |
| `/api/executors/:type/config` | GET | Get executor configuration |
| `/api/executors/:type/config` | PUT | Update executor configuration |
| `/api/mcp/servers` | GET | List MCP server configurations |
| `/api/mcp/servers` | PUT | Update MCP configurations |

### OAuth & Authentication

**Module:** `crates/server/src/routes/oauth.rs` (10,809 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/oauth/github/device` | POST | Start GitHub device auth flow |
| `/api/oauth/github/callback` | GET | GitHub OAuth callback |
| `/api/oauth/github/status` | GET | Check auth status |

### Organizations

**Module:** `crates/server/src/routes/organizations.rs` (7,507 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/organizations` | GET | List organizations |
| `/api/organizations/:id` | GET | Get organization details |

### Repository Operations

**Module:** `crates/server/src/routes/repo.rs` (6,662 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/repos` | GET | List repositories |
| `/api/repos/:id/branches` | GET | List branches |
| `/api/repos/:id/status` | GET | Get repo git status |

### Filesystem

**Module:** `crates/server/src/routes/filesystem.rs` (2,652 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/filesystem/browse` | GET | Browse directories |
| `/api/filesystem/validate` | POST | Validate path |

### Images

**Module:** `crates/server/src/routes/images.rs` (9,080 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/images` | POST | Upload image |
| `/api/images/:id` | GET | Get image |
| `/api/images/:id` | DELETE | Delete image |

### Containers

**Module:** `crates/server/src/routes/containers.rs` (2,280 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/containers` | GET | List git worktree containers |
| `/api/containers/:id` | DELETE | Delete container |

### Scratch/Drafts

**Module:** `crates/server/src/routes/scratch.rs` (5,297 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/scratch` | GET | Get scratch content |
| `/api/scratch` | PUT | Save scratch content |

### Terminal

**Module:** `crates/server/src/routes/terminal.rs` (5,020 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/terminal/ws/:process_id` | WS | WebSocket for terminal output |

### Approvals

**Module:** `crates/server/src/routes/approvals.rs` (1,488 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/approvals` | GET | Get pending approvals |
| `/api/approvals/:id` | POST | Submit approval response |

### Events (WebSocket)

**Module:** `crates/server/src/routes/events.rs` (801 bytes)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/events/ws` | WS | Real-time database changes (Electric) |

## WebSocket Channels

### Database Change Stream

**Endpoint:** `/api/events/ws`

Streams real-time database changes using Electric sync protocol. Used by TanStack Query for cache invalidation.

### Process Output Stream

**Endpoint:** `/api/terminal/ws/:process_id`

Streams live terminal output from agent execution processes.

## Error Handling

All endpoints return standard error format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message"
  }
}
```

Common HTTP status codes:
- `200` - Success
- `201` - Created
- `400` - Bad request
- `404` - Not found
- `500` - Internal server error

## Type Safety

All request/response types are defined in Rust with `#[derive(TS)]` and exported to `shared/types.ts` for frontend consumption.

---

*Generated by BMAD Document Project Workflow v1.2.0*
