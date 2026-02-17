# Vibe Kanban - Architecture Documentation

> Technical architecture for AI coding agent orchestration platform

## Architecture Overview

Vibe Kanban follows a **Layered Full-Stack Architecture** with clear separation between:

1. **Presentation Layer** - React SPA with component-based UI
2. **API Layer** - Axum REST + WebSocket server
3. **Service Layer** - Rust business logic modules
4. **Data Layer** - SQLite (local) / PostgreSQL (remote)
5. **Integration Layer** - AI agent executor abstractions

```
┌────────────────────────────────────────────────────────────────┐
│                     Presentation Layer                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    React SPA (Vite)                       │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐        │  │
│  │  │Components│ │ Hooks   │ │ Stores  │ │Contexts │        │  │
│  │  │(Radix UI)│ │(85+ h.) │ │(Zustand)│ │(React)  │        │  │
│  │  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘        │  │
│  │       └───────────┴──────────┴───────────┘               │  │
│  │                         │                                 │  │
│  │              ┌──────────▼──────────┐                     │  │
│  │              │   TanStack Query    │                     │  │
│  │              │   + WebSocket       │                     │  │
│  │              └──────────┬──────────┘                     │  │
│  └─────────────────────────│────────────────────────────────┘  │
│                            │ HTTP/WS                            │
├────────────────────────────│────────────────────────────────────┤
│                     API Layer                                    │
│  ┌─────────────────────────▼────────────────────────────────┐  │
│  │                  Axum Server (Rust)                       │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │                    Routes                            │ │  │
│  │  │  /api/projects  /api/tasks  /api/workspaces  ...   │ │  │
│  │  └──────────────────────┬──────────────────────────────┘ │  │
│  │                         │                                 │  │
│  │  ┌──────────┐  ┌───────▼───────┐  ┌──────────────────┐  │  │
│  │  │Middleware│  │ tower-http    │  │ MCP Server       │  │  │
│  │  │(CORS,etc)│  │ (static files)│  │ Integration      │  │  │
│  │  └──────────┘  └───────────────┘  └──────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                     Service Layer                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     Services Crate                        │  │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────────────┐   │  │
│  │  │TaskService │ │WorkspaceS. │ │ExecutionService    │   │  │
│  │  └─────┬──────┘ └─────┬──────┘ └─────────┬──────────┘   │  │
│  │        └──────────────┴──────────────────┘               │  │
│  └──────────────────────────│───────────────────────────────┘  │
│                             │                                   │
├─────────────────────────────│───────────────────────────────────┤
│                     Data Layer                                   │
│  ┌──────────────────────────▼───────────────────────────────┐  │
│  │                      DB Crate                             │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │  │
│  │  │   Models    │  │   Queries   │  │   Migrations    │  │  │
│  │  │(SQLx types) │  │ (compile-   │  │ (65+ files)     │  │  │
│  │  │             │  │  time safe) │  │                 │  │  │
│  │  └──────┬──────┘  └──────┬──────┘  └────────┬────────┘  │  │
│  │         └────────────────┴──────────────────┘            │  │
│  │                          │                                │  │
│  │         ┌────────────────┼────────────────┐              │  │
│  │         ▼                ▼                ▼              │  │
│  │    ┌─────────┐     ┌──────────┐    ┌──────────┐        │  │
│  │    │ SQLite  │     │PostgreSQL│    │ Electric │        │  │
│  │    │ (local) │     │ (remote) │    │  (sync)  │        │  │
│  │    └─────────┘     └──────────┘    └──────────┘        │  │
│  └──────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                     Integration Layer                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Executors Crate                         │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │              Executor Trait (async)                 │  │  │
│  │  └─────────────────────────┬──────────────────────────┘  │  │
│  │                            │                              │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐        │  │
│  │  │ Claude  │ │ Gemini  │ │  Codex  │ │ Cursor  │  ...   │  │
│  │  │  Code   │ │   CLI   │ │(OpenAI) │ │   CLI   │        │  │
│  │  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘        │  │
│  │       └───────────┴──────────┴───────────┘               │  │
│  │                         │                                 │  │
│  │              ┌──────────▼──────────┐                     │  │
│  │              │   Process Groups    │                     │  │
│  │              │   (tokio + nix)     │                     │  │
│  │              └─────────────────────┘                     │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Technology Decisions

### Backend Technology Choices

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Language | Rust | Performance, safety, cross-platform binaries |
| Async Runtime | Tokio | Industry standard, excellent ecosystem |
| Web Framework | Axum | Type-safe, tower-based, modern API |
| Database | SQLite/PostgreSQL | Local-first with remote option |
| ORM | SQLx | Compile-time query verification |
| Type Generation | ts-rs | Rust → TypeScript type safety |

### Frontend Technology Choices

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | React 18 | Component model, ecosystem |
| Build Tool | Vite | Fast dev server, modern bundling |
| Styling | TailwindCSS | Utility-first, design consistency |
| State | Zustand + TanStack Query | Simple global + server state |
| UI Components | Radix UI | Accessible, unstyled primitives |

## Data Architecture

### Core Entities

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Project   │────<│    Task     │────<│  Workspace  │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Repository  │     │   Tag       │     │  Session    │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │Exec Process │
                                        └─────────────┘
```

### Key Relationships

- **Project** has many **Tasks** and **Repositories**
- **Task** has many **Workspaces** (isolated git worktrees)
- **Workspace** has many **Sessions** (agent execution runs)
- **Session** has many **Execution Processes** (agent + dev server processes)

### Database Schema (Key Tables)

| Table | Purpose |
|-------|---------|
| `projects` | Project configuration and metadata |
| `project_repositories` | Git repositories linked to projects |
| `tasks` | Task definitions with descriptions |
| `task_tags` | Tag categorization for tasks |
| `workspaces` | Git worktree instances |
| `sessions` | Agent execution sessions |
| `execution_processes` | Running process tracking |
| `execution_process_logs` | Process output logs |
| `coding_agent_turns` | Agent conversation turns |

## API Design

### REST Endpoints

| Endpoint Pattern | Purpose |
|-----------------|---------|
| `GET/POST /api/projects` | Project CRUD |
| `GET/POST /api/tasks` | Task management |
| `GET/POST /api/workspaces` | Workspace operations |
| `POST /api/workspaces/:id/sessions` | Start agent session |
| `GET /api/execution-processes/:id/logs` | Process output |
| `GET /api/settings` | Application settings |

### WebSocket Channels

| Channel | Purpose |
|---------|---------|
| `/api/ws/changes` | Real-time database changes (Electric) |
| `/api/ws/process/:id` | Live process output streaming |

## Component Architecture (Frontend)

### Component Hierarchy

```
App.tsx
├── Layout/
│   ├── Sidebar (project navigation)
│   ├── Header (actions, settings)
│   └── MainContent
│       ├── KanbanBoard
│       │   ├── KanbanColumn
│       │   └── TaskCard
│       ├── TaskDetail
│       │   ├── TaskHeader
│       │   ├── TaskDescription (Lexical editor)
│       │   └── WorkspaceList
│       └── WorkspaceView
│           ├── DiffViewer
│           ├── TerminalOutput (xterm.js)
│           └── SessionControls
└── Dialogs/
    ├── CreateProjectDialog
    ├── CreateTaskDialog
    └── SettingsDialog
```

### State Management Pattern

```typescript
// Zustand for UI state
const useUIStore = create((set) => ({
  selectedProject: null,
  selectedTask: null,
  sidebarOpen: true,
}))

// TanStack Query for server state
const { data: tasks } = useQuery({
  queryKey: ['tasks', projectId],
  queryFn: () => api.getTasks(projectId)
})

// Contexts for cross-cutting concerns
<WebSocketProvider>
  <SettingsProvider>
    <KeyboardShortcutProvider>
      <App />
    </KeyboardShortcutProvider>
  </SettingsProvider>
</WebSocketProvider>
```

## Executor Architecture

### Executor Trait

```rust
#[async_trait]
pub trait Executor: Send + Sync {
    async fn start(&self, config: ExecutorConfig) -> Result<ExecutorHandle>;
    async fn send_message(&self, message: String) -> Result<()>;
    async fn stop(&self) -> Result<()>;
    fn executor_type(&self) -> ExecutorType;
}
```

### Supported Executors

| Executor | Protocol | Communication |
|----------|----------|---------------|
| ClaudeCode | agent-client-protocol | Subprocess + IPC |
| GeminiCLI | Custom JSON | Subprocess + stdout |
| Codex | codex-protocol | HTTP API |
| CursorCLI | Custom | Subprocess |
| GitHubCopilot | Custom | Subprocess |

## Deployment Modes

### Local Mode (Default)

- SQLite database in user data directory
- Single binary distribution via npm
- Embedded static frontend assets

### Remote Mode

- PostgreSQL database
- Docker Compose deployment
- Electric for real-time sync
- GitHub App integration for webhooks

## Security Considerations

1. **CORS**: Configurable allowed origins via `VK_ALLOWED_ORIGINS`
2. **Local-first**: No network required for basic operation
3. **API Keys**: Stored in secure system keychain via agents
4. **Process Isolation**: Agent processes run in isolated process groups

---

*Generated by BMAD Document Project Workflow v1.2.0*
