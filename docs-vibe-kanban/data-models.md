# Vibe Kanban - Data Models

> Database schema and entity documentation

## Database Overview

| Aspect | Local Mode | Remote Mode |
|--------|------------|-------------|
| **Database** | SQLite | PostgreSQL |
| **ORM** | SQLx (compile-time verified) | SQLx |
| **Migrations** | `crates/db/migrations/` (65+ files) | `crates/remote/migrations/` |
| **Sync** | Electric | Electric |

## Core Entities

### Entity Relationship Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Project   │────<│    Task     │────<│  Workspace  │
│             │     │             │     │             │
│ id          │     │ id          │     │ id          │
│ name        │     │ title       │     │ task_id     │
│ created_at  │     │ description │     │ branch      │
│ updated_at  │     │ status      │     │ container   │
└──────┬──────┘     │ project_id  │     │ created_at  │
       │            │ parent_id   │     └──────┬──────┘
       │            └──────┬──────┘            │
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ ProjectRepo │     │  TaskTag    │     │   Session   │
│             │     │ (junction)  │     │             │
│ id          │     │             │     │ id          │
│ project_id  │     │ task_id     │     │ workspace_id│
│ path        │     │ tag_id      │     │ executor    │
│ name        │     └─────────────┘     │ status      │
└─────────────┘                         └──────┬──────┘
                                               │
       ┌─────────────┐                        │
       │    Tag      │                        │
       │             │                        ▼
       │ id          │                 ┌─────────────┐
       │ name        │                 │ExecProcess  │
       │ color       │                 │             │
       │ project_id  │                 │ id          │
       └─────────────┘                 │ session_id  │
                                       │ run_reason  │
                                       │ executor    │
                                       │ status      │
                                       └──────┬──────┘
                                              │
                                              ▼
                                       ┌─────────────┐
                                       │ ProcessLogs │
                                       │             │
                                       │ process_id  │
                                       │ content     │
                                       │ timestamp   │
                                       └─────────────┘
```

## Model Files

### Project Models

**File:** `crates/db/src/models/project.rs` (7,913 bytes)

```rust
pub struct Project {
    pub id: Uuid,
    pub name: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}
```

**File:** `crates/db/src/models/project_repo.rs` (5,158 bytes)

```rust
pub struct ProjectRepo {
    pub id: Uuid,
    pub project_id: Uuid,
    pub path: String,
    pub name: String,
    pub default_target_branch: Option<String>,
    // Script configurations
    pub dev_script: Option<String>,
    pub cleanup_script: Option<String>,
    pub setup_script: Option<String>,
    pub parallel_setup_script: Option<String>,
}
```

### Task Models

**File:** `crates/db/src/models/task.rs` (12,439 bytes)

```rust
pub struct Task {
    pub id: Uuid,
    pub title: String,
    pub description: Option<String>,
    pub status: TaskStatus,
    pub project_id: Uuid,
    pub parent_id: Option<Uuid>,  // Subtask support
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

pub enum TaskStatus {
    Todo,
    InProgress,
    Review,
    Done,
}
```

**File:** `crates/db/src/models/tag.rs` (3,104 bytes)

```rust
pub struct Tag {
    pub id: Uuid,
    pub name: String,
    pub color: String,
    pub project_id: Uuid,
}
```

### Workspace Models

**File:** `crates/db/src/models/workspace.rs` (25,160 bytes - largest model)

```rust
pub struct Workspace {
    pub id: Uuid,
    pub task_id: Uuid,
    pub branch: String,
    pub container_ref: String,  // Git worktree path
    pub base_branch: String,
    pub pr_url: Option<String>,
    pub pr_number: Option<i32>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}
```

**File:** `crates/db/src/models/workspace_repo.rs` (10,005 bytes)

```rust
pub struct WorkspaceRepo {
    pub workspace_id: Uuid,
    pub repo_id: Uuid,
    pub worktree_path: String,
}
```

### Session Models

**File:** `crates/db/src/models/session.rs` (5,036 bytes)

```rust
pub struct Session {
    pub id: Uuid,
    pub workspace_id: Uuid,
    pub executor: ExecutorType,
    pub status: SessionStatus,
    pub assistant_message: Option<String>,
    pub created_at: DateTime<Utc>,
}

pub enum SessionStatus {
    Active,
    Completed,
    Failed,
    Stopped,
}
```

### Execution Process Models

**File:** `crates/db/src/models/execution_process.rs` (29,323 bytes)

```rust
pub struct ExecutionProcess {
    pub id: Uuid,
    pub session_id: Uuid,
    pub run_reason: RunReason,
    pub executor_action: Option<ExecutorAction>,
    pub executor_type: ExecutorType,
    pub status: ProcessStatus,
    pub before_head_commit: Option<String>,
    pub after_head_commit: Option<String>,
    pub masked_by_restore: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

pub enum RunReason {
    Agent,
    DevServer,
    CleanupScript,
    SetupScript,
    ParallelSetupScript,
}

pub enum ProcessStatus {
    Running,
    Completed,
    Failed,
    Stopped,
}
```

**File:** `crates/db/src/models/execution_process_logs.rs` (2,074 bytes)

```rust
pub struct ExecutionProcessLog {
    pub process_id: Uuid,
    pub content: String,
    pub timestamp: DateTime<Utc>,
}
```

### Coding Agent Turn Models

**File:** `crates/db/src/models/coding_agent_turn.rs` (7,228 bytes)

```rust
pub struct CodingAgentTurn {
    pub id: Uuid,
    pub session_id: Uuid,
    pub role: TurnRole,
    pub content: String,
    pub seen: bool,
    pub created_at: DateTime<Utc>,
}

pub enum TurnRole {
    User,
    Assistant,
    System,
}
```

### Image Models

**File:** `crates/db/src/models/image.rs` (7,426 bytes)

```rust
pub struct Image {
    pub id: Uuid,
    pub filename: String,
    pub content_type: String,
    pub data: Vec<u8>,
    pub created_at: DateTime<Utc>,
}

// Junction tables for image associations
pub struct TaskImage {
    pub task_id: Uuid,
    pub image_id: Uuid,
}

pub struct WorkspaceImage {
    pub workspace_id: Uuid,
    pub image_id: Uuid,
}
```

### Merge Models

**File:** `crates/db/src/models/merge.rs` (11,893 bytes)

```rust
pub struct Merge {
    pub id: Uuid,
    pub workspace_id: Uuid,
    pub merge_commit: String,
    pub status: MergeStatus,
    pub created_at: DateTime<Utc>,
}

pub enum MergeStatus {
    Pending,
    Completed,
    Conflicted,
    Aborted,
}
```

### Scratch/Draft Models

**File:** `crates/db/src/models/scratch.rs` (9,444 bytes)

```rust
pub struct Scratch {
    pub id: Uuid,
    pub workspace_id: Uuid,
    pub content: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}
```

### Repository Models

**File:** `crates/db/src/models/repo.rs` (10,631 bytes)

```rust
pub struct Repo {
    pub id: Uuid,
    pub path: String,
    pub name: String,
    pub remote_url: Option<String>,
}
```

## Migration History

The project has 65+ migrations tracking schema evolution:

| Date Range | Focus Area |
|------------|------------|
| Jun 2025 | Initial schema, tasks, projects |
| Jul 2025 | Worktrees, branches, PR tracking |
| Aug 2025 | Images, executor types |
| Sep 2025 | Session refactoring |
| Oct 2025 | Tags (replacing templates) |
| Nov 2025 | Electric sync support |
| Dec 2025 | Workspaces/sessions split |
| Jan 2026 | Performance indexes |

## Type Generation

All models with `#[derive(TS)]` are exported to `shared/types.ts`:

```rust
#[derive(Debug, Serialize, Deserialize, TS)]
#[ts(export)]
pub struct Task {
    // ... fields
}
```

Frontend imports:
```typescript
import { Task, Workspace, Session } from 'shared/types'
```

---

*Generated by BMAD Document Project Workflow v1.2.0*
