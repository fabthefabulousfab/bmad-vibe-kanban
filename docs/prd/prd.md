---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-03-success
  - step-04-journeys
  - step-05-domain
  - step-06-innovation
  - step-07-project-type
  - step-08-scoping
  - step-09-functional
  - step-10-nonfunctional
  - step-11-polish
  - step-12-complete
inputDocuments:
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
workflowType: 'prd'
projectType: 'brownfield'
classification:
  projectType: developer_tool + desktop_app + saas_b2b
  domain: general
  complexity: medium-high
  projectContext: brownfield
documentCounts:
  briefs: 0
  research: 0
  projectDocs: 13
  reconciliation: 1
---

# Product Requirements Document - Vibe Kanban

**Author:** Fabulousfab
**Date:** 2026-02-18
**Source:** Reverse-engineered from codebase analysis (brownfield)

## Executive Summary

### Vision

Vibe Kanban is a local-first developer productivity platform that orchestrates AI coding agents through isolated git worktrees, enabling developers and teams to manage parallel coding tasks with full control over agent execution, real-time streaming of results, and seamless cloud synchronization for team collaboration.

### Product Differentiator

Unlike cloud-only AI coding platforms, Vibe Kanban runs locally on the developer's machine with an embedded React frontend served from a single Rust binary. It isolates every coding task into its own git worktree, supports 9 different AI coding agents through a unified Executor trait, and streams agent output in real-time via SSE and WebSocket. The cloud platform extends this with organization management, issue tracking, PR reviews, and billing -- but the core value is local-first autonomy.

### Target Users

1. **Solo developers** seeking AI-assisted coding workflows with multiple agent options and parallel task execution
2. **Development teams** managing multi-repository projects that require git worktree isolation and coordinated task management
3. **Organizations** requiring code review automation, team collaboration through cloud-hosted issue tracking, and centralized billing

### Core Capabilities

- Multi-agent orchestration (Claude Code, Gemini, Codex, Cursor, Copilot, Amp, QwenCode, Opencode, Droid)
- Git worktree isolation for parallel task execution across multiple repositories
- Real-time streaming of agent execution output (SSE/WebSocket)
- Local-first architecture with SQLite persistence and cloud sync
- Organization-level project management with Kanban-style issue tracking
- PR review automation via GitHub App integration
- Cross-platform distribution (macOS Intel/ARM, Linux x64/ARM64, Windows x64) via npx CLI

## Success Criteria

### User Success

- Developers can start a new AI-assisted coding task in under 30 seconds, with full git worktree isolation requiring zero manual branch or directory management
- Developers can run multiple AI agents in parallel across different tasks without cross-contamination of code changes
- Developers can switch between 9 AI coding agents without reconfiguring their project setup
- Teams can track issues, review PRs, and manage projects through a unified cloud dashboard synchronized with local workspaces

### Business Success

- Adoption: Active daily users managing 3+ concurrent workspaces per session
- Retention: Developers return to use the tool daily for AI-assisted coding tasks
- Team conversion: Solo users convert to team plans within 30 days of initial adoption
- Platform stickiness: Users leverage 2+ AI agent types regularly, demonstrating value of the multi-agent approach

### Technical Success

- Local server starts and serves embedded frontend within 3 seconds
- Agent execution streams output to UI with under 500ms latency
- Git worktree creation completes within 2 seconds for repositories under 1GB
- Cloud sync (ElectricSQL) reflects changes in remote frontend within 5 seconds
- Cross-platform binaries function identically across all 6 supported platform targets
- SQLite database handles 100+ concurrent workspace sessions without degradation

### Measurable Outcomes

- 95% of coding agent spawns complete without error across all 9 executor types
- PR review pipeline processes submissions within 60 seconds of upload
- Zero data loss during workspace cleanup operations (worktree removal)
- OAuth token refresh succeeds silently with zero user-visible interruptions

## Product Scope

### MVP - Minimum Viable Product

The MVP is the current state of the product, which is fully operational:

- Local desktop application with embedded React SPA served from Rust binary
- Project and task management (CRUD) with SQLite persistence
- Workspace lifecycle (create, start, merge, archive, pin, rename)
- Git worktree isolation for all workspaces across multi-repo projects
- Support for 9 AI coding agents via the Executor trait
- Real-time execution streaming via SSE and WebSocket
- Diff visualization and statistics computation
- Tool call approval system for agent actions
- Configuration management (editor settings, themes, i18n in 7 languages)
- File system browsing and code search (ripgrep-based)
- Integrated terminal (PTY via xterm.js)
- Image upload and management for tasks
- NPX CLI distribution wrapper with platform-specific binary downloads

### Growth Features (Post-MVP)

- Cloud platform with organization management and team collaboration
- Issue tracking with Kanban board, relationships, comments, followers, and assignees
- PR review automation via GitHub App webhooks
- Stripe-integrated billing and subscription management
- Data migration between local and remote servers
- Remote frontend (SaaS portal) for organization-level operations
- ElectricSQL real-time sync between cloud PostgreSQL and remote frontend
- PR monitoring service (background polling every 60 seconds)
- Notification service (cross-platform sound and push notifications)

### Vision (Future)

- Full remote deployment mode (cloud-native variant implementing the Deployment trait)
- Advanced multi-agent coordination (agents collaborating on the same task)
- Code review AI with deeper static analysis integration
- Plugin ecosystem for custom executor types
- Marketplace for agent configurations and MCP server templates
- Advanced analytics and reporting on developer productivity metrics

## User Journeys

### Journey 1: Solo Developer -- First Task with AI Agent

**Alex**, a senior backend developer, discovers Vibe Kanban and wants to try using Claude Code to implement a new API endpoint.

**Opening Scene:** Alex installs via `npx vibe-kanban`, which downloads the platform-specific binary to `~/.vibe-kanban/bin/`. The local server starts, opens the embedded React frontend in the browser, and presents the project setup wizard.

**Rising Action:** Alex adds their repository, the system detects it as a git repo and creates a project entry. Alex creates a new task "Add user preferences endpoint", clicks "Start Workspace", selects Claude Code as the executor, and provides a base branch. Behind the scenes, Vibe Kanban creates a git worktree at `{worktree_base}/{workspace_id}/{repo_name}`, checks out a fresh branch, and spawns Claude Code in the isolated directory.

**Climax:** Claude Code begins working. The SSE stream delivers real-time stdout/stderr to the UI. Alex watches the agent write code, can see live diff statistics updating, and when Claude Code requests permission to run a shell command, the approval dialog appears. Alex approves, and the agent continues. The task completes with all changes isolated in the worktree branch.

**Resolution:** Alex reviews the diff, is satisfied, clicks "Merge". The squash merge integrates changes back to the target branch. The worktree is cleaned up. Alex has a clean commit on their main branch with zero manual git operations required.

### Journey 2: Solo Developer -- Parallel Multi-Agent Workflow

**Priya**, a full-stack developer, needs to work on three tasks simultaneously across two repositories.

**Opening Scene:** Priya has a project with a backend repo and a frontend repo. She has three tasks: a backend API change, a frontend component, and a bug fix in the backend.

**Rising Action:** Priya creates three workspaces, each getting its own git worktrees for both repos. She starts the first with Claude Code, the second with Gemini, and the third with Cursor. Each agent works in complete isolation. She can switch between workspace views to monitor each agent's progress via the real-time execution streams.

**Climax:** All three agents work concurrently without conflict. The diff stream service shows real-time statistics for each workspace. When Gemini finishes first, Priya reviews its output, makes a follow-up request (using the session continuation feature), and eventually merges. The other agents continue undisturbed.

**Resolution:** All three tasks complete. Priya merges each workspace's changes back independently. No merge conflicts from the worktree isolation. Three features delivered in the time it would normally take for one.

### Journey 3: Team Lead -- Cloud Organization Setup

**Marcus**, a development team lead, wants to onboard his team of 5 developers onto Vibe Kanban with shared project management.

**Opening Scene:** Marcus logs into the remote frontend (SaaS portal) via GitHub OAuth. He creates an organization, sets up billing through Stripe, and creates a project linked to their repositories.

**Rising Action:** Marcus installs the GitHub App on the organization's repositories, enabling webhook-based PR monitoring. He creates issues in the Kanban board, assigns them to team members, and configures project statuses (custom Kanban columns). Team members install Vibe Kanban locally and authenticate via OAuth, linking their local instances to the cloud organization.

**Climax:** A developer starts a workspace linked to an issue. When they merge locally, Vibe Kanban creates a PR via the GitHub integration. The PR monitor service detects the PR, the team reviews it through the platform. The issue status updates automatically. Marcus sees the Kanban board update in real-time via ElectricSQL sync.

**Resolution:** The team manages their entire development workflow -- from issue creation through code generation to PR merge -- through a single integrated platform. Marcus has visibility into all team activity through the cloud dashboard.

### Journey 4: Developer -- Error Recovery and Troubleshooting

**Sam**, a developer, encounters issues during an agent execution.

**Opening Scene:** Sam starts a workspace and launches Claude Code to refactor a complex module. Partway through execution, the agent encounters an error and the execution process status changes to "Failed".

**Rising Action:** Sam checks the execution process logs via the SSE stream history (MsgStore retains 100MB of history). The error is in a tool call that requires a dependency not present in the worktree. Sam opens the integrated terminal (PTY via WebSocket) connected to the workspace directory, installs the dependency, and creates a follow-up session to continue the agent's work.

**Climax:** The follow-up session picks up context from the previous session. The agent completes the refactoring. Sam uses the diff viewer to review all changes across the full session chain.

**Resolution:** Sam merges the changes. The worktree is cleaned up. The execution process chain (setup script, coding agent, follow-up) is preserved in the session history for future reference.

### Journey 5: API Consumer -- MCP Integration

**DevOps Team** integrates Vibe Kanban into their CI/CD pipeline using the MCP (Model Context Protocol) server.

**Opening Scene:** The DevOps team needs to automate workspace creation and task management from their build scripts and automation tools.

**Rising Action:** They configure their AI tooling to connect to Vibe Kanban's MCP server. Using the MCP tools, they can list projects, create issues, start workspace sessions, and link workspaces to issues programmatically. Each workspace session specifies the executor, repositories with base branches, and an optional issue linkage.

**Climax:** Automated workflows create workspaces in response to new issues, run AI agents to generate initial implementations, and produce PRs for human review.

**Resolution:** The team achieves a semi-automated development pipeline where AI agents handle routine coding tasks under human oversight, managed entirely through the MCP API.

### Journey Requirements Summary

| Journey | Capabilities Revealed |
|---------|----------------------|
| Solo First Task | Project setup, workspace creation, worktree isolation, agent spawning, real-time streaming, approval system, diff review, merge |
| Parallel Multi-Agent | Multi-workspace management, concurrent agent execution, session continuation, independent merge |
| Team Cloud Setup | Organization management, GitHub OAuth, billing, issue tracking, PR monitoring, real-time sync |
| Error Recovery | Log history, integrated terminal, follow-up sessions, session chaining, diff across sessions |
| MCP Integration | Programmatic API, workspace automation, issue linkage, executor configuration |

## Domain-Specific Requirements

The project operates in the **general software development tooling** domain with **no regulated-industry compliance requirements** (no HIPAA, PCI-DSS, GDPR data processing, or FedRAMP mandates).

Domain-specific concerns focus on:

### Developer Experience Constraints

- Zero-configuration startup: The tool must work after `npx vibe-kanban` with no additional setup beyond git repository availability
- Agent compatibility: Each of the 9 executors has different CLI interfaces, log formats, and capabilities that must be normalized to a consistent experience
- Git safety: Worktree operations must never corrupt the user's repository or lose uncommitted work

### Security Boundary

- Local-first means sensitive code never leaves the developer's machine unless explicitly pushed via git
- OAuth tokens stored on disk must be protected (currently using file-system permissions)
- The approval system gates agent tool calls, preventing unauthorized file deletion, command execution, or network access
- Origin validation (CSRF-like) protects the local HTTP server from cross-origin attacks

### Integration Constraints

- GitHub App integration requires webhook endpoint availability on the cloud platform
- ElectricSQL sync requires persistent connection between remote frontend and PostgreSQL
- Stripe billing integration requires webhook endpoint for subscription lifecycle events
- Each AI coding agent requires its own CLI binary installed on the developer's machine

## Innovation Analysis

### Competitive Differentiation

| Innovation | Description | Competitive Advantage |
|------------|-------------|----------------------|
| **Local-first with embedded SPA** | Single Rust binary embeds the entire React frontend via rust-embed | No Docker, no separate server -- one binary does everything |
| **Git worktree isolation** | Each workspace gets independent worktrees per repository | True parallel task execution without branch juggling |
| **9-agent unified interface** | Executor trait normalizes Claude, Gemini, Codex, Cursor, Copilot, Amp, QwenCode, Opencode, Droid | Agent-agnostic workflow -- switch agents without changing workflow |
| **Real-time event sourcing** | SQLite hooks generate JSON Patches pushed via MsgStore to SSE/WebSocket | Instant UI updates for all database changes without polling |
| **Deployment trait abstraction** | Same route handlers work for local (SQLite) and cloud (PostgreSQL) | Single codebase serves desktop and cloud deployments |
| **MCP server integration** | Model Context Protocol enables AI tools to manage Vibe Kanban programmatically | Composable with any MCP-aware AI toolchain |

### Technology Choices

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Backend language | Rust (nightly) | Performance, memory safety, single-binary compilation |
| Frontend framework | React 18 + Vite 5 | Ecosystem maturity, developer familiarity |
| Local database | SQLite | Zero-configuration, single-file, embedded in process |
| Remote database | PostgreSQL | Relational integrity, ElectricSQL compatibility |
| Distribution | npx CLI wrapper + Cloudflare R2 | Zero-install experience, global CDN delivery |
| State management | Zustand (5 stores) + React Context (25 providers) | Lightweight for global state, scoped for component state |
| Real-time sync | ElectricSQL | Postgres-to-frontend sync without custom infrastructure |

## Project-Type Requirements

### Desktop Application Requirements

- **Cross-platform support:** macOS (Intel/ARM), Linux (x64/ARM64), Windows (x64) -- 6 platform targets
- **Auto-update mechanism:** NPX CLI wrapper checks for new versions on each invocation via Cloudflare R2
- **System integration:** PTY terminal access, file system browsing, git operations via libgit2
- **Offline capability:** Full local operation without cloud connectivity; cloud features degrade gracefully
- **Code signing:** Apple Developer ID certificate for macOS, with notarization via `xcrun notarytool`

### SaaS Platform Requirements

- **Multi-tenancy:** Organization-based tenant isolation in PostgreSQL
- **Authentication:** GitHub OAuth and Google OAuth with PKCE flow; JWT session tokens with AES-256-GCM encryption at rest
- **Authorization:** Organization membership check (`ensure_project_access`) for all project operations
- **Billing:** Stripe subscription management with webhook-driven lifecycle events
- **API design:** RESTful endpoints with consistent error response format

### Developer Tool Requirements

- **CLI interface:** `npx vibe-kanban` entry point with automatic platform detection and binary download
- **Configuration:** Versioned JSON config (v8) with editor settings, themes, and agent profiles
- **Extensibility:** MCP server for programmatic access; executor profiles for custom agent configurations
- **Observability:** PostHog analytics (opt-in), Sentry error tracking, execution process logs with full history
- **Internationalization:** 7 language translations in the frontend

## Functional Requirements

### Project Management

- FR1: Developers can create, read, update, and delete projects with associated repository configurations
- FR2: Developers can add multiple repositories to a project, establishing a multi-repo workspace context
- FR3: Developers can set a default AI agent working directory per project
- FR4: Developers can discover git repositories on their local filesystem via automated scanning
- FR5: Developers can configure repository-level setup scripts, cleanup scripts, and dev server scripts

### Task Management

- FR6: Developers can create, read, update, and delete tasks within a project
- FR7: Developers can assign tasks a status from a defined set (Todo, InProgress, InReview, Done, Cancelled)
- FR8: Developers can attach images to tasks for visual context
- FR9: Developers can tag tasks for categorization using project-level tags
- FR10: Developers can associate tasks with remote issues for cloud synchronization

### Workspace Lifecycle

- FR11: Developers can create workspaces (isolated working environments) for tasks
- FR12: The system creates git worktrees for each repository in the project when a workspace starts
- FR13: Developers can start workspace execution, selecting an AI coding agent and base branches
- FR14: Developers can archive, pin, and rename workspaces
- FR15: Developers can merge workspace changes back to target branches via squash merge
- FR16: Developers can create pull requests from workspace branches via GitHub integration
- FR17: The system cleans up git worktrees when workspaces are removed

### AI Agent Execution

- FR18: Developers can spawn coding agent sessions using any of the 9 supported executors
- FR19: Developers can send follow-up messages to continue existing coding agent sessions
- FR20: Developers can fork existing sessions to create alternative execution paths
- FR21: The system normalizes agent output into a unified log stream regardless of executor type
- FR22: Developers can view real-time execution output via SSE streaming
- FR23: Developers can kill running execution processes
- FR24: The system tracks execution process status (Running, Completed, Failed, Killed)
- FR25: Developers can run setup scripts before and cleanup scripts after agent execution
- FR26: Developers can start dev server scripts within workspace context
- FR27: The system records per-repo git state (before/after head commits) for each execution process

### Approval System

- FR28: Developers can view pending tool call approval requests from AI agents
- FR29: Developers can approve or reject individual tool calls before agent execution proceeds
- FR30: The approval system supports per-execution-process approval queues

### Real-Time Communication

- FR31: The system pushes database changes to the frontend in real-time via JSON Patch events over SSE
- FR32: The system provides real-time diff statistics during agent execution via SSE
- FR33: Developers can access scratch pad content updates in real-time via WebSocket
- FR34: The system maintains a 100MB in-memory message history buffer for late-joining subscribers

### Code Review and Diff

- FR35: Developers can view diff statistics (files changed, lines added/removed) per workspace
- FR36: Developers can stream real-time diff updates during active execution
- FR37: The system tracks merge history (direct merge and PR merge) per workspace per repository
- FR38: The PR monitor service polls PR status every 60 seconds for active pull requests

### File System and Search

- FR39: Developers can browse directory trees and read file contents from repositories
- FR40: Developers can write files to repository directories
- FR41: Developers can search code across repositories using pattern matching (ripgrep-based)
- FR42: The system caches file search results with git history ranking for performance

### Configuration and Personalization

- FR43: Developers can configure application settings (editor preferences, notification settings, themes)
- FR44: Developers can manage executor profiles to customize agent behavior per project
- FR45: The system supports 7 language translations via i18n
- FR46: Developers can configure MCP servers for agent tool augmentation

### Terminal Access

- FR47: Developers can open interactive terminal sessions within workspace directories via WebSocket-backed PTY

### Cloud Organization Management

- FR48: Organization admins can create and manage organizations on the cloud platform
- FR49: Organization admins can invite and manage team members with role-based access
- FR50: Team members can authenticate via GitHub OAuth or Google OAuth with PKCE
- FR51: The system enforces organization-level access control for all project operations

### Cloud Issue Tracking

- FR52: Team members can create, update, and bulk-update issues within cloud projects
- FR53: Team members can assign issues to team members and manage followers
- FR54: Team members can add threaded comments to issues
- FR55: Team members can define issue relationships (dependencies, blocks, relates-to)
- FR56: Team members can tag and categorize issues
- FR57: Organization admins can define custom project statuses (Kanban columns)

### Cloud Integration

- FR58: The system syncs project data between local desktop and cloud platform via migration service
- FR59: The system integrates with GitHub App for repository access, webhook events, and PR management
- FR60: The system provides ElectricSQL-based real-time sync from PostgreSQL to remote frontend

### Billing

- FR61: Organization admins can manage subscriptions via Stripe integration
- FR62: The system handles subscription lifecycle events via Stripe webhooks

### Notifications

- FR63: The system delivers cross-platform notifications (sound and push) for relevant events
- FR64: Team members can view and manage notification queues on the cloud platform

### MCP Server

- FR65: External tools can manage projects, tasks, and workspaces programmatically via MCP protocol
- FR66: External tools can start workspace sessions specifying executor type, repository configurations, and issue linkage

## Non-Functional Requirements

### Performance

- NFR1: The local server starts and serves the embedded frontend within 3 seconds on standard developer hardware
- NFR2: Real-time SSE event delivery latency is under 500ms from database change to frontend receipt
- NFR3: Git worktree creation completes within 2 seconds for repositories under 1GB
- NFR4: Code search (ripgrep-based) returns results within 1 second for repositories under 500K lines
- NFR5: The MsgStore broadcast channel supports 10,000 message capacity with 100MB history buffer
- NFR6: File search cache uses git history ranking to return most-relevant results first

### Security

- NFR7: All communication between local frontend and backend is protected by origin validation (CSRF-like mechanism via VK_ALLOWED_ORIGINS)
- NFR8: OAuth tokens are persisted on disk with filesystem-level access protection and automatic refresh before expiration
- NFR9: Remote server JWT tokens are encrypted at rest using AES-256-GCM
- NFR10: Remote API enforces organization membership checks on all project-scoped operations
- NFR11: GitHub App webhook payloads are validated using shared secrets
- NFR12: No sensitive credentials are hardcoded; all secrets use environment variables

### Scalability

- NFR13: The local SQLite database supports 100+ concurrent workspace sessions with DELETE journal mode for compatibility
- NFR14: The remote PostgreSQL database supports 25+ tables with proper indexing for multi-tenant queries
- NFR15: The broadcast channel (10,000 capacity) and FIFO eviction (100MB) handle high-frequency database change events without memory exhaustion
- NFR16: Cross-platform binary distribution supports 6 platform targets via Cloudflare R2 CDN

### Reliability

- NFR17: Git worktree operations never corrupt the parent repository; cleanup procedures remove orphaned worktrees
- NFR18: Execution process failures are captured with exit codes and status tracking; no silent failures
- NFR19: The PR monitor service recovers gracefully from network failures with 60-second polling interval
- NFR20: ElectricSQL sync handles temporary disconnection and reconciles state on reconnection

### Integration

- NFR21: The Executor trait provides a consistent interface for all 9 AI coding agents, normalizing logs, capabilities, and lifecycle management
- NFR22: GitHub App integration supports both OAuth token-based and installation token-based authentication
- NFR23: Stripe billing integration handles subscription creation, updates, cancellation, and payment failure events
- NFR24: TypeScript type generation (ts-rs) ensures frontend and backend types are always synchronized at build time

### Maintainability

- NFR25: The Rust workspace is organized into 10 crates with a clean layered dependency hierarchy (server -> deployment -> services -> db/git/executors -> utils)
- NFR26: The frontend follows Container/View pattern with 220+ components across 90+ UI elements
- NFR27: All database schema changes are managed through sequential migrations (69 migrations as of current state)
- NFR28: Shared types between Rust and TypeScript are auto-generated, eliminating manual synchronization

---

*Generated from codebase analysis using BMAD PRD Workflow. All functional requirements reverse-engineered from existing implementation. All non-functional requirements derived from observed technical constraints and architecture decisions.*
