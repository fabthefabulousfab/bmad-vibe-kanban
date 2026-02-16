# Vibe Kanban - Integration Architecture

> How the parts of the monorepo communicate and integrate

## Part Overview

| Part | Type | Purpose | Communication |
|------|------|---------|---------------|
| **frontend** | React SPA | User interface | HTTP/WS → backend |
| **backend** (crates/) | Rust API | Business logic | SQLite + Agent spawning |
| **shared** | TypeScript | Type definitions | Import only |
| **npx-cli** | Node wrapper | Distribution | Spawns backend binary |
| **remote-frontend** | React SPA | Remote UI | HTTP/WS → remote backend |

## Integration Points

### 1. Frontend ↔ Backend API

```
┌─────────────────────┐         ┌─────────────────────┐
│      Frontend       │         │      Backend        │
│  (React + Vite)     │         │  (Axum + Rust)      │
│                     │         │                     │
│  TanStack Query ────┼── HTTP ─┼──► /api/projects    │
│  useQuery/Mutation  │  REST   │    /api/tasks       │
│                     │         │    /api/workspaces  │
│                     │         │    /api/sessions    │
│  WebSocket Provider ┼── WS ───┼──► /api/ws/changes  │
│  (real-time sync)   │         │    /api/ws/process  │
└─────────────────────┘         └─────────────────────┘
```

**Key Integration Details:**

- Vite proxy forwards `/api/*` to backend port
- TanStack Query handles caching and refetching
- WebSocket provides real-time updates via Electric sync
- All API types defined in Rust, generated to TypeScript

### 2. Type Sharing (ts-rs)

```
┌─────────────────────────────────────────────────────────────┐
│                        Rust Crates                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  db/models  │  │   server/   │  │ executors/  │         │
│  │             │  │   routes    │  │   types     │         │
│  │ #[derive(TS)]  #[derive(TS)]    #[derive(TS)] │         │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘         │
│         └────────────────┴────────────────┘                 │
│                          │                                  │
│              cargo run --bin generate_types                 │
│                          │                                  │
│                          ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  shared/types.ts                      │  │
│  │  export interface Task { id: string; title: string }  │  │
│  │  export type ExecutorType = "CLAUDE_CODE" | ...       │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ import
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                        Frontend                              │
│  import { Task, ExecutorType } from 'shared/types'          │
└─────────────────────────────────────────────────────────────┘
```

**Workflow:**

1. Add `#[derive(TS)]` and `#[ts(export)]` to Rust types
2. Run `pnpm run generate-types`
3. Types appear in `shared/types.ts`
4. Frontend imports from `shared/types`

### 3. Backend ↔ AI Agents (Executors)

```
┌─────────────────────────────────────────────────────────────┐
│                    Backend Server                            │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  services/                            │  │
│  │  ExecutionService                                     │  │
│  │    │                                                  │  │
│  │    │ spawn_session()                                  │  │
│  │    ▼                                                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                  │
│          ┌───────────────┼───────────────┐                 │
│          ▼               ▼               ▼                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │ClaudeCode   │ │GeminiCLI    │ │CodexExecutor│ ...      │
│  │Executor     │ │Executor     │ │             │          │
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘          │
│         │               │               │                  │
│         ▼               ▼               ▼                  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              command-group (tokio)                   │  │
│  │              Process group management                │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ subprocess
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    External Processes                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │ claude      │ │ gemini      │ │ codex       │           │
│  │ (CLI)       │ │ (CLI)       │ │ (API)       │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

**Protocol Details:**

| Executor | Communication Method | Protocol |
|----------|---------------------|----------|
| Claude Code | Subprocess + agent-client-protocol | JSON-RPC over stdio |
| Gemini CLI | Subprocess + stdout parsing | Custom JSON lines |
| Codex | HTTP API + codex-protocol | REST/WebSocket |
| Cursor CLI | Subprocess | Custom |

### 4. NPX CLI ↔ Binary Distribution

```
┌─────────────────────────────────────────────────────────────┐
│                    npm install vibe-kanban                   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                   npx-cli/                            │  │
│  │  bin/cli.js                                           │  │
│  │    │                                                  │  │
│  │    ├─── Detect platform (darwin, linux, win32)       │  │
│  │    ├─── Detect arch (x64, arm64)                     │  │
│  │    └─── Spawn correct binary                         │  │
│  │                                                       │  │
│  │  dist/                                                │  │
│  │    ├── vibe-kanban-darwin-arm64                      │  │
│  │    ├── vibe-kanban-darwin-x64                        │  │
│  │    ├── vibe-kanban-linux-x64                         │  │
│  │    └── vibe-kanban-win32-x64.exe                     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 5. Database Layer Integration

```
┌─────────────────────────────────────────────────────────────┐
│                    crates/server/                            │
│                         │                                    │
│                         │ uses                               │
│                         ▼                                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    crates/db/                         │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐     │  │
│  │  │  Models    │  │  Queries   │  │Migrations  │     │  │
│  │  │ (structs)  │  │  (sqlx)    │  │ (.sql)     │     │  │
│  │  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘     │  │
│  │        └───────────────┴───────────────┘             │  │
│  └──────────────────────────────────────────────────────┘  │
│                         │                                   │
│         ┌───────────────┴───────────────┐                  │
│         ▼                               ▼                  │
│  ┌─────────────────┐            ┌─────────────────┐       │
│  │ local-deployment │            │     remote      │       │
│  │     (SQLite)     │            │  (PostgreSQL)   │       │
│  └─────────────────┘            └─────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow Examples

### Creating a Task

```
1. User clicks "New Task" in Frontend
   │
   ▼
2. Frontend calls POST /api/tasks
   │  { title, description, projectId }
   ▼
3. Axum route handler validates
   │
   ▼
4. services::TaskService::create()
   │
   ▼
5. db::tasks::insert()
   │
   ▼
6. SQLite INSERT (or PostgreSQL for remote)
   │
   ▼
7. WebSocket broadcasts change via Electric
   │
   ▼
8. Frontend TanStack Query cache invalidates
   │
   ▼
9. UI updates with new task
```

### Executing an Agent

```
1. User clicks "Run Agent" in Frontend
   │
   ▼
2. Frontend calls POST /api/workspaces/:id/sessions
   │  { executor: "CLAUDE_CODE", message: "..." }
   ▼
3. services::ExecutionService::start_session()
   │
   ├──► Create git worktree (isolated branch)
   │
   ├──► Select executor based on type
   │
   └──► executors::ClaudeCodeExecutor::start()
        │
        ▼
4. Spawn claude CLI process in worktree
   │
   ▼
5. Stream output to execution_process_logs
   │
   ▼
6. Frontend WebSocket receives live updates
   │
   ▼
7. Terminal displays agent output in real-time
```

## Configuration Integration

### MCP (Model Context Protocol)

```
┌─────────────────────────────────────────────────────────────┐
│                    Settings (UI)                             │
│  MCP Server Configuration                                    │
│  ┌────────────────────────────────────────────────────┐     │
│  │  { "servers": { "filesystem": { ... } } }          │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ stored in
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend                                   │
│  ~/.config/vibe-kanban/mcp-config.json                      │
│                          │                                   │
│                          │ passed to                         │
│                          ▼                                   │
│  Executor spawn with MCP_CONFIG env var                     │
│                          │                                   │
│                          ▼                                   │
│  Agent reads and connects to configured MCP servers         │
└─────────────────────────────────────────────────────────────┘
```

## Future Integration: BMAD

Based on user context, a planned integration would add:

```
┌─────────────────────────────────────────────────────────────┐
│                    BMAD Integration (Future)                 │
│                                                              │
│  _bmad-output/                                               │
│    ├── implementation-artifacts/                             │
│    │     ├── sprint-status.yaml                             │
│    │     └── epics/                                          │
│    │           └── epic-*.md                                 │
│                          │                                   │
│                          │ parsed by                         │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Vibe Kanban (New Feature)                │  │
│  │  - Auto-import stories as tasks at startup            │  │
│  │  - Map story status to Kanban columns                 │  │
│  │  - Execute with /bmad:bmm:workflows:dev-story        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

*Generated by BMAD Document Project Workflow v1.2.0*
