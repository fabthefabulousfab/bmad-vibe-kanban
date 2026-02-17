# Data Models Documentation

## Overview

The bmad-vibe-kanban system uses two separate databases for local and remote operations:

- **Local Database**: SQLite database for desktop application data
- **Remote Database**: PostgreSQL database for cloud-based collaboration and organization management

This document details all data models, their relationships, and the evolution of the schema through migrations.

---

## Local Database (SQLite)

### Database Technology

- **ORM**: sqlx with compile-time query checking
- **Type Generation**: ts-rs for automatic TypeScript type export
- **Migration Management**: 44 migrations from June 2025 to February 2026
- **Event Hooks**: SQLite triggers for real-time updates via MsgStore

### Core Tables

#### 1. projects

Represents development projects that organize tasks and repositories.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| name | TEXT | NOT NULL | Project name |
| default_agent_working_dir | TEXT | NULL | Default working directory for coding agents |
| remote_project_id | BLOB | NULL | Foreign key to remote PostgreSQL project |
| created_at | TEXT | NOT NULL | Creation timestamp (ISO 8601) |
| updated_at | TEXT | NOT NULL | Last update timestamp |

**Relationships**:
- One-to-many with `tasks`
- Many-to-many with `repos` through `project_repos`

**Key Operations**:
- `find_all()`: Get all projects ordered by creation date
- `find_most_active()`: Get projects with recent workspace activity
- `find_by_remote_project_id()`: Link local to remote projects

---

#### 2. repos

Represents Git repositories that can be associated with multiple projects.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| path | TEXT | UNIQUE, NOT NULL | Absolute filesystem path |
| name | TEXT | NOT NULL | Repository name (derived from path) |
| display_name | TEXT | NOT NULL | User-friendly display name |
| setup_script | TEXT | NULL | Script to run when setting up workspace |
| cleanup_script | TEXT | NULL | Script to run when cleaning up workspace |
| archive_script | TEXT | NULL | Script to run when archiving workspace |
| copy_files | TEXT | NULL | JSON array of file patterns to copy |
| parallel_setup_script | BOOL | NOT NULL | Whether setup script can run in parallel |
| dev_server_script | TEXT | NULL | Script to start development server |
| default_target_branch | TEXT | NULL | Default branch for new workspaces |
| default_working_dir | TEXT | NULL | Default working directory within repo |
| created_at | TEXT | NOT NULL | Creation timestamp |
| updated_at | TEXT | NOT NULL | Last update timestamp |

**Relationships**:
- Many-to-many with `projects` through `project_repos`
- Many-to-many with `workspaces` through `workspace_repos`

**Migration History**:
- Migration 20260107000000: Moved scripts from projects to repos (setup, cleanup, dev_server)
- Migration 20260203000000: Added archive_script for workspace archival
- Migration 20260122000000: Added default_target_branch
- Migration 20260126000000: Added default_working_dir

---

#### 3. project_repos

Junction table for many-to-many relationship between projects and repositories.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| project_id | BLOB | FOREIGN KEY | References projects(id) |
| repo_id | BLOB | FOREIGN KEY | References repos(id) |

**Purpose**: Enables multi-repository projects introduced in migration 20251209000000.

---

#### 4. tasks

Represents individual work items within a project.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| project_id | BLOB | FOREIGN KEY | References projects(id) |
| title | TEXT | NOT NULL | Task title |
| description | TEXT | NULL | Markdown description |
| status | TEXT | CHECK constraint | One of: todo, inprogress, inreview, done, cancelled |
| parent_workspace_id | BLOB | FOREIGN KEY | References workspaces(id), for subtasks |
| created_at | TEXT | NOT NULL | Creation timestamp |
| updated_at | TEXT | NOT NULL | Last update timestamp |

**Relationships**:
- Belongs to one `project`
- Has many `workspaces` (execution attempts)
- Optional parent `workspace` for task hierarchy
- Has many `task_images` for attached images

**Task Status Enum**:
- `todo`: Not started
- `inprogress`: Currently being worked on
- `inreview`: Awaiting review
- `done`: Completed
- `cancelled`: Cancelled

**Migration History**:
- Migration 20250716170000: Added parent_task field (later renamed to parent_workspace_id)
- Migration 20251216142123: Renamed parent_task_attempt to parent_workspace_id

---

#### 5. workspaces

Represents isolated development environments for task execution. Formerly called `task_attempts`.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| task_id | BLOB | FOREIGN KEY | References tasks(id) |
| container_ref | TEXT | NULL | Filesystem path to workspace directory |
| branch | TEXT | NOT NULL | Git branch name for this workspace |
| agent_working_dir | TEXT | NULL | Working directory for coding agent |
| setup_completed_at | TEXT | NULL | Timestamp when setup completed |
| created_at | TEXT | NOT NULL | Creation timestamp |
| updated_at | TEXT | NOT NULL | Last update timestamp |
| archived | BOOL | NOT NULL, DEFAULT 0 | Whether workspace is archived |
| pinned | BOOL | NOT NULL, DEFAULT 0 | Whether workspace is pinned in UI |
| name | TEXT | NULL | User-defined or auto-generated workspace name |

**Relationships**:
- Belongs to one `task`
- Has many `sessions` (execution sessions)
- Has many `workspace_repos` (multi-repo support)
- Has many `merges` (PR/merge tracking)

**Migration History**:
- Migration 20251216142123: Major refactoring - renamed from `task_attempts` to `workspaces`
- Migration 20250701000000: Added branch field
- Migration 20250710000000: Added setup_completed_at
- Migration 20251221000000: Added archived and pinned flags
- Migration 20251216142123: Moved executor field to sessions table

**Workspace Lifecycle**:
1. Created with a branch name
2. Container ref assigned when workspace directory created
3. Setup script runs, setup_completed_at set on success
4. Coding agent executes within workspace
5. Can be archived (accelerated cleanup after 1 hour)
6. Cleanup after 72 hours of inactivity (1 hour if archived)

---

#### 6. workspace_repos

Junction table linking workspaces to repositories with target branches. Supports multi-repository workspaces.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| workspace_id | BLOB | FOREIGN KEY | References workspaces(id) |
| repo_id | BLOB | FOREIGN KEY | References repos(id) |
| target_branch | TEXT | NOT NULL | Target branch for merge/PR |
| created_at | TEXT | NOT NULL | Creation timestamp |
| updated_at | TEXT | NOT NULL | Last update timestamp |

**Migration History**:
- Migration 20251216142123: Renamed from `attempt_repos` to `workspace_repos`
- Migration 20251209000000: Initially created as `attempt_repos`

---

#### 7. sessions

Represents coding agent execution sessions within a workspace.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| workspace_id | BLOB | FOREIGN KEY | References workspaces(id) |
| executor | TEXT | NULL | Executor type (e.g., "CLAUDE_CODE", "AMP") |
| created_at | TEXT | NOT NULL | Creation timestamp |
| updated_at | TEXT | NOT NULL | Last update timestamp |

**Relationships**:
- Belongs to one `workspace`
- Has many `execution_processes`

**Migration History**:
- Migration 20251216142123: Created as part of workspace refactoring
- Migration 20251220134608: Fixed executor format (SCREAMING_SNAKE_CASE)

**Purpose**: Separates workspace (git state) from execution session (agent invocation), allowing multiple sessions per workspace.

---

#### 8. execution_processes

Represents individual process executions (setup scripts, coding agents, dev servers, cleanup).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| session_id | BLOB | FOREIGN KEY | References sessions(id) |
| run_reason | TEXT | CHECK constraint | setupscript, codingagent, devserver, cleanupscript |
| executor_action | TEXT | NOT NULL, DEFAULT '{}' | JSON executor action data |
| status | TEXT | CHECK constraint | running, completed, failed, killed |
| exit_code | INTEGER | NULL | Process exit code |
| dropped | INTEGER | NOT NULL, DEFAULT 0 | Whether process output is dropped |
| started_at | TEXT | NOT NULL | Start timestamp |
| completed_at | TEXT | NULL | Completion timestamp |
| created_at | TEXT | NOT NULL | Creation timestamp |
| updated_at | TEXT | NOT NULL | Last update timestamp |

**Relationships**:
- Belongs to one `session`
- Has many `execution_process_logs`
- Has many `execution_process_repo_states`
- Has many `coding_agent_turns`

**Run Reason Enum**:
- `setupscript`: Setup script execution
- `codingagent`: Coding agent execution
- `devserver`: Development server
- `cleanupscript`: Cleanup script execution

**Status Enum**:
- `running`: Currently executing
- `completed`: Finished successfully
- `failed`: Failed with error
- `killed`: Terminated by user

**Migration History**:
- Migration 20250620212427: Created execution_processes table
- Migration 20250730000000: Added executor_action field
- Migration 20250730000001: Renamed process_type to run_reason
- Migration 20251216142123: Changed FK from task_attempt_id to session_id

---

#### 9. execution_process_logs

Stores raw log output from execution processes.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| execution_process_id | BLOB | FOREIGN KEY | References execution_processes(id) |
| data | BLOB | NOT NULL | Raw log data (binary) |

**Note**: No primary key (composite key on execution_process_id). Optimized for append-only log streaming.

**Migration History**:
- Migration 20250729162941: Created table
- Migration 20251101090000: Dropped primary key for performance

---

#### 10. execution_process_repo_states

Tracks git commit state changes for each repository in a workspace during execution.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| execution_process_id | BLOB | FOREIGN KEY | References execution_processes(id) |
| repo_id | BLOB | FOREIGN KEY | References repos(id) |
| before_head_commit | TEXT | NULL | Commit SHA before execution |
| after_head_commit | TEXT | NULL | Commit SHA after execution |
| merge_commit | TEXT | NULL | Merge commit SHA if merged |

**Purpose**: Enables diff computation and rollback functionality.

**Migration History**:
- Migration 20250905090000: Added after_head_commit
- Migration 20250910120000: Added before_head_commit

---

#### 11. coding_agent_turns

Tracks individual conversation turns within a coding agent execution. Formerly called `executor_sessions`.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| execution_process_id | BLOB | FOREIGN KEY | References execution_processes(id) |
| agent_session_id | TEXT | NULL | Agent's internal session ID |
| prompt | TEXT | NULL | User prompt text |
| summary | TEXT | NULL | Agent's response summary |
| seen | BOOL | NOT NULL, DEFAULT 0 | Whether user has seen this turn |
| agent_message_id | TEXT | NULL | Agent's message ID for follow-ups |
| created_at | TEXT | NOT NULL | Creation timestamp |
| updated_at | TEXT | NOT NULL | Last update timestamp |

**Migration History**:
- Migration 20250623120000: Created as `executor_sessions`
- Migration 20251216142123: Renamed to `coding_agent_turns`
- Migration 20260107115155: Added `seen` flag
- Migration 20260123125956: Added `agent_message_id`

---

#### 12. images

Stores uploaded images with content-addressed deduplication via SHA256 hash.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| file_path | TEXT | NOT NULL | Filesystem path to image |
| original_name | TEXT | NOT NULL | Original filename |
| mime_type | TEXT | NULL | MIME type (e.g., image/png) |
| size_bytes | INTEGER | NOT NULL | File size in bytes |
| hash | TEXT | NOT NULL | SHA256 hash for deduplication |
| created_at | TEXT | NOT NULL | Creation timestamp |
| updated_at | TEXT | NOT NULL | Last update timestamp |

**Migration History**:
- Migration 20250818150000: Refactored to use junction table pattern

---

#### 13. task_images

Junction table for many-to-many relationship between tasks and images.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| task_id | BLOB | FOREIGN KEY | References tasks(id) |
| image_id | BLOB | FOREIGN KEY | References images(id) |
| created_at | TEXT | NOT NULL | Creation timestamp |

**Purpose**: Allows attaching multiple images to tasks and reusing images across tasks.

---

#### 14. merges

Tracks merge operations (direct merges and pull requests) per workspace per repository.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| workspace_id | BLOB | FOREIGN KEY | References workspaces(id) |
| repo_id | BLOB | FOREIGN KEY | References repos(id) |
| merge_type | TEXT | NOT NULL | "direct" or "pr" |
| merge_commit | TEXT | NULL | Commit SHA of merge |
| target_branch_name | TEXT | NOT NULL | Target branch for merge |
| pr_number | INTEGER | NULL | Pull request number |
| pr_url | TEXT | NULL | Pull request URL |
| pr_status | TEXT | NULL | open, merged, closed, unknown |
| pr_merged_at | TEXT | NULL | PR merge timestamp |
| pr_merge_commit_sha | TEXT | NULL | PR merge commit SHA |
| created_at | TEXT | NOT NULL | Creation timestamp |

**Merge Type**:
- `direct`: Direct merge to target branch
- `pr`: Pull request merge

**PR Status**:
- `open`: PR is open
- `merged`: PR has been merged
- `closed`: PR closed without merging
- `unknown`: Status unknown

**Migration History**:
- Migration 20250819000000: Created merges table, moved merge_commit from workspaces
- Migration 20251216142123: Renamed task_attempt_id to workspace_id

---

#### 15. tags

User-defined tags for organizing tasks within a project. Formerly called `task_templates`.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| project_id | BLOB | FOREIGN KEY | References projects(id) |
| name | TEXT | NOT NULL | Tag name |
| is_default | BOOL | NOT NULL, DEFAULT 0 | Whether tag is default for new tasks |
| created_at | TEXT | NOT NULL | Creation timestamp |
| updated_at | TEXT | NOT NULL | Last update timestamp |

**Migration History**:
- Migration 20250715154859: Created as `task_templates`
- Migration 20251020120000: Converted from templates to tags

---

#### 16. scratch

General-purpose scratch storage for draft data, notes, and temporary state.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| scratch_type | TEXT | NOT NULL | Type of scratch data |
| entity_id | BLOB | NOT NULL | Related entity ID |
| payload | TEXT | NOT NULL | JSON payload |
| created_at | TEXT | NOT NULL | Creation timestamp |
| updated_at | TEXT | NOT NULL | Last update timestamp |

**Scratch Types**:
- `DraftFollowUp`: Draft follow-up messages for workspaces

**Migration History**:
- Migration 20250906120000: Created as `follow_up_drafts`
- Migration 20250921222241: Unified into `drafts` table
- Migration 20251120000001: Renamed to `scratch` for generalization

---

#### 17. migration_state

Tracks migration state between local and remote databases for data synchronization.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BLOB | PRIMARY KEY | UUID identifier |
| organization_id | BLOB | NOT NULL | Organization ID on remote server |
| project_id | BLOB | NULL | Project ID on remote server |
| entity_type | TEXT | NOT NULL | Type of entity (project, task, etc.) |
| local_id | BLOB | NOT NULL | Local database entity ID |
| remote_id | BLOB | NOT NULL | Remote database entity ID |
| created_at | TEXT | NOT NULL | Creation timestamp |

**Purpose**: Enables bidirectional sync between local SQLite and remote PostgreSQL databases.

**Migration History**:
- Migration 20260128000000: Created migration_state table

---

## Schema Evolution Timeline

### Phase 1: Initial Schema (June 2025)

- **20250617183714_init.sql**: Initial schema with projects, tasks, task_attempts, task_attempt_activities

### Phase 2: Execution Processes (June-July 2025)

- **20250620212427**: Created execution_processes table
- **20250620214100**: Removed stdout/stderr from task_attempts
- **20250621120000**: Related activities to execution_processes
- **20250623120000**: Created executor_sessions (later coding_agent_turns)

### Phase 3: Git Workflow Features (July-August 2025)

- **20250701000000**: Added branch to task_attempts
- **20250701000001**: Added PR tracking fields
- **20250709000000**: Added worktree_deleted flag
- **20250710000000**: Added setup completion tracking
- **20250715154859**: Added task_templates (later tags)

### Phase 4: Executor Action Refactoring (July-August 2025)

- **20250730000000**: Added executor_action to execution_processes
- **20250730000001**: Renamed process_type to run_reason
- **20250805112332**: Added executor_action_type virtual column
- **20250813000001**: Renamed base_coding_agent to profile

### Phase 5: Image Management (August 2025)

- **20250818150000**: Refactored images to junction table pattern
- **20250819000000**: Moved merge_commit to merges table

### Phase 6: Template to Tag Conversion (September-October 2025)

- **20250902184501**: Renamed profile to executor
- **20250903091032**: Changed executors to SCREAMING_SNAKE_CASE
- **20250921222241**: Unified drafts tables
- **20251020120000**: Converted templates to tags

### Phase 7: Multi-Repository Support (December 2025)

- **20251209000000**: Added project_repositories and attempt_repos tables
- **20251215145026**: Dropped worktree_deleted flag

### Phase 8: Workspace/Session Split (December 2025)

- **20251216142123**: **Major refactoring**
  - Renamed task_attempts to workspaces
  - Created sessions table
  - Moved executor from workspaces to sessions
  - Renamed executor_sessions to coding_agent_turns
  - Renamed attempt_repos to workspace_repos
  - Updated all foreign key references

### Phase 9: Workspace Features (December 2025 - January 2026)

- **20251219000000**: Added agent_working_dir to projects
- **20251221000000**: Added archived and pinned flags to workspaces
- **20260107000000**: Moved scripts from projects to repos
- **20260107115155**: Added seen flag to coding_agent_turns

### Phase 10: Performance and Remote Sync (January-February 2026)

- **20260112160045**: Added composite indexes for performance
- **20260113144821**: Removed shared_tasks table
- **20260122000000**: Added default_target_branch to repos
- **20260123125956**: Added agent_message_id to coding_agent_turns
- **20260126000000**: Added agent_working_dir to repos
- **20260128000000**: Added migration_state table
- **20260203000000**: Added archive_script to repos

---

## Remote Database (PostgreSQL)

The remote server uses PostgreSQL with 25+ tables for cloud-based collaboration. Key tables include:

### Organization Management

- **organizations**: Organization entities with billing information
- **organization_members**: Members with roles (owner, admin, member, guest)
- **organization_member_profiles**: Extended profile information
- **invitations**: Pending organization invitations

### Project Management

- **projects**: Remote projects linked to local projects via remote_project_id
- **project_statuses**: Configurable workflow statuses per project
- **tags**: Project tags for issue organization

### Issue Tracking

- **issues**: Remote tasks/issues with extended metadata
- **issue_comments**: Threaded comments on issues
- **issue_comment_reactions**: Emoji reactions to comments
- **issue_assignees**: Many-to-many issue assignments
- **issue_followers**: Issue subscription/notification tracking
- **issue_tags**: Many-to-many issue tagging
- **issue_relationships**: Parent/child issue relationships

### Pull Requests

- **pull_requests**: PR metadata synced from GitHub/Azure DevOps
- **pull_request_statuses**: PR review status tracking

### User Management

- **users**: User accounts with OAuth provider integration
- **sessions**: JWT session tokens for authentication
- **tokens**: API tokens for programmatic access
- **notifications**: User notification queue

### Workspace Tracking

- **workspaces**: Remote workspace records linked to local workspaces

### Billing

- **billing_customers**: Stripe customer records
- **billing_subscriptions**: Subscription status and tier

### Real-time Sync

- **Electric SQL integration**: Real-time sync via Electric proxy for collaboration

---

## Entity Relationship Overview

### Local Database Relationships

```
projects (1) ---> (*) tasks
projects (*) <---> (*) repos [via project_repos]

tasks (1) ---> (*) workspaces
tasks (*) <---> (*) images [via task_images]
tasks (*) ---> (1) workspaces [parent_workspace_id, optional]

workspaces (1) ---> (*) sessions
workspaces (*) <---> (*) repos [via workspace_repos]
workspaces (1) ---> (*) merges

sessions (1) ---> (*) execution_processes

execution_processes (1) ---> (*) execution_process_logs
execution_processes (1) ---> (*) execution_process_repo_states
execution_processes (1) ---> (*) coding_agent_turns

repos (*) <---> (*) projects [via project_repos]
repos (*) <---> (*) workspaces [via workspace_repos]
repos (1) ---> (*) execution_process_repo_states
repos (1) ---> (*) merges

tags (*) ---> (1) projects
```

### Key Cardinalities

- **Project to Tasks**: One project has many tasks
- **Project to Repos**: Many-to-many (a project can use multiple repos, a repo can be used in multiple projects)
- **Task to Workspaces**: One task has many workspaces (execution attempts)
- **Workspace to Sessions**: One workspace has many sessions (agent invocations)
- **Session to Execution Processes**: One session has many processes (setup, agent, cleanup)
- **Workspace to Repos**: Many-to-many (multi-repo workspaces)

### Task Hierarchy

Tasks can form a tree structure via `parent_workspace_id`:
- A workspace can spawn child tasks via "Create Task from Follow-up"
- Child task's `parent_workspace_id` references the parent workspace
- This creates a task hierarchy: Parent Task -> Parent Workspace -> Child Task -> Child Workspace -> Grandchild Task

---

## Data Access Patterns

### Read-Heavy Queries

1. **List workspaces with status**: Complex query joining workspaces, sessions, execution_processes
2. **List tasks with attempt status**: Complex query with subqueries for running/failed status
3. **Find most active projects**: Queries projects with recent workspace activity

### Write-Heavy Operations

1. **Execution process log streaming**: High-frequency append-only writes to execution_process_logs
2. **Real-time event hooks**: SQLite triggers fire on INSERT/UPDATE to push events via MsgStore

### Performance Optimizations

- Composite indexes on frequently queried columns (migration 20260112160045)
- Dropped primary key on execution_process_logs for append performance (migration 20251101090000)
- Cached file search with git history ranking

---

*Generated by BMAD Document Project Workflow v1.2.0 (Deep Scan)*
