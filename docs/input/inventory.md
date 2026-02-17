# Document Inventory

> Imported: 2026-02-17
> Total documents: 109 files
> Source: bmad-vibe-kanban project (fork of Vibe Kanban 0.1.4 with BMAD integration)

---

## Summary

| Category | Files | BMAD Target Directory |
|----------|-------|-----------------------|
| Project Root | 5 | `docs/input/` (reference) |
| Vibe Kanban Technical | 81 | `docs/architecture/`, `docs/design/` |
| Integration & Fork | 14 | `docs/input/` (reference) |
| BMAD Methodology | 7 | `docs/brief/`, `docs/prd/` |
| Plans | 2 | `docs/input/` (reference) |
| **Total** | **109** | |

---

## 1. Project Root Documents

Reference documents that define the overall project scope and context.

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `project-root/README.md` | Project overview, quick start, fork info, license | Input for Product Brief |
| `project-root/DOCUMENTATION.md` | Master documentation index (all docs organized by topic) | Reference map |
| `project-root/CODE-OF-CONDUCT.md` | Community guidelines (Apache 2.0 derived) | Non-functional requirement |
| `project-root/RESTORATION-VERIFICATION.md` | Verification of fork restoration to v0.1.4 | Historical reference |
| `project-root/build-instructions.md` | Multi-platform installer build instructions | Input for Architecture |

---

## 2. Vibe Kanban Technical Documentation (81 files)

### 2.1 Core Technical Documentation

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/index.md` | Documentation index with tech stack overview | Input for Architecture |
| `vibe-kanban/project-overview.md` | Executive summary, capabilities | Input for Product Brief |
| `vibe-kanban/architecture.md` | System design, data models, API patterns | Input for Architecture |
| `vibe-kanban/source-tree-analysis.md` | Annotated directory structure | Input for Architecture |
| `vibe-kanban/development-guide.md` | Setup, commands, workflows | Developer reference |
| `vibe-kanban/api-contracts.md` | REST endpoint documentation | Input for Architecture |
| `vibe-kanban/data-models.md` | Database schema details (SQLite) | Input for Architecture |
| `vibe-kanban/component-inventory.md` | React component catalog | Input for Architecture/Design |
| `vibe-kanban/BUILD-GUIDE.md` | Complete build documentation | Developer reference |
| `vibe-kanban/TESTING-CHECKLIST.md` | Testing procedures (6 phases) | Input for Test Strategy |
| `vibe-kanban/CLAUDE-VERIFICATION-GUIDE.md` | Claude Code verification quick reference | Developer reference |
| `vibe-kanban/README.md` | Docs directory readme | Navigation |

### 2.2 Metadata Files

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/docs.json` | Mintlify documentation config | Reference |
| `vibe-kanban/project-scan-report.json` | Project scan metadata | Reference |

### 2.3 User Documentation - Getting Started

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/index.mdx` | Mintlify landing page | Input for Design |
| `vibe-kanban/getting-started.mdx` | Quick start guide | Input for Design |
| `vibe-kanban/supported-coding-agents.mdx` | Supported agent list | Input for Product Brief |
| `vibe-kanban/troubleshooting.mdx` | Troubleshooting guide | Reference |

### 2.4 Agent Guides (10 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/agents/amp.mdx` | AMP agent setup | Feature reference |
| `vibe-kanban/agents/ccr.mdx` | CCR agent config | Feature reference |
| `vibe-kanban/agents/claude-code.mdx` | Claude Code integration | Feature reference |
| `vibe-kanban/agents/cursor-cli.mdx` | Cursor CLI agent | Feature reference |
| `vibe-kanban/agents/droid.mdx` | Droid agent guide | Feature reference |
| `vibe-kanban/agents/gemini-cli.mdx` | Gemini CLI agent | Feature reference |
| `vibe-kanban/agents/github-copilot.mdx` | GitHub Copilot agent | Feature reference |
| `vibe-kanban/agents/openai-codex.mdx` | OpenAI Codex agent | Feature reference |
| `vibe-kanban/agents/opencode.mdx` | OpenCode agent | Feature reference |
| `vibe-kanban/agents/qwen-code.mdx` | Qwen Code agent | Feature reference |

### 2.5 Cloud Features (13 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/cloud/index.mdx` | Cloud overview | Feature reference (N/A for fork) |
| `vibe-kanban/cloud/getting-started.mdx` | Cloud setup | Feature reference (N/A for fork) |
| `vibe-kanban/cloud/authentication.mdx` | Auth flows | Feature reference (N/A for fork) |
| `vibe-kanban/cloud/customisation.mdx` | Cloud customization | Feature reference (N/A for fork) |
| `vibe-kanban/cloud/filtering.mdx` | Filtering features | Feature reference |
| `vibe-kanban/cloud/issues.mdx` | Issue management | Feature reference |
| `vibe-kanban/cloud/kanban-board.mdx` | Kanban board UI | Feature reference |
| `vibe-kanban/cloud/list-view.mdx` | List view UI | Feature reference |
| `vibe-kanban/cloud/migration.mdx` | Migration guide | Feature reference (N/A for fork) |
| `vibe-kanban/cloud/organizations.mdx` | Organization management | Feature reference (N/A for fork) |
| `vibe-kanban/cloud/projects.mdx` | Project management | Feature reference |
| `vibe-kanban/cloud/team-members.mdx` | Team management | Feature reference (N/A for fork) |
| `vibe-kanban/cloud/troubleshooting.mdx` | Cloud troubleshooting | Reference |

### 2.6 Core Features (9 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/core-features/completing-a-task.mdx` | Task completion flows | Input for PRD |
| `vibe-kanban/core-features/creating-projects.mdx` | Project creation | Input for PRD |
| `vibe-kanban/core-features/creating-tasks.mdx` | Task creation | Input for PRD |
| `vibe-kanban/core-features/monitoring-task-execution.mdx` | Task monitoring | Input for PRD |
| `vibe-kanban/core-features/new-task-attempts.mdx` | Task retry mechanism | Input for PRD |
| `vibe-kanban/core-features/resolving-rebase-conflicts.mdx` | Rebase conflict resolution | Input for PRD |
| `vibe-kanban/core-features/reviewing-code-changes.mdx` | Code review features | Input for PRD |
| `vibe-kanban/core-features/subtasks.mdx` | Subtask management | Input for PRD |
| `vibe-kanban/core-features/testing-your-application.mdx` | Testing features | Input for PRD/Test Strategy |

### 2.7 Configuration & Customisation (4 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/configuration-customisation/agent-configurations.mdx` | Agent config UI | Input for Design |
| `vibe-kanban/configuration-customisation/creating-task-tags.mdx` | Tag management | Input for Design |
| `vibe-kanban/configuration-customisation/global-settings.mdx` | Global settings | Input for Design |
| `vibe-kanban/configuration-customisation/keyboard-shortcuts.mdx` | Keyboard shortcuts | Input for Design |

### 2.8 Settings Beta (8 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/settings-beta/index.mdx` | Settings overview | Input for Design |
| `vibe-kanban/settings-beta/agent-configurations.mdx` | Agent settings | Input for Design |
| `vibe-kanban/settings-beta/creating-task-tags.mdx` | Tag creation settings | Input for Design |
| `vibe-kanban/settings-beta/general.mdx` | General settings | Input for Design |
| `vibe-kanban/settings-beta/mcp-servers.mdx` | MCP server config | Input for Architecture |
| `vibe-kanban/settings-beta/organization-settings.mdx` | Org settings | Input for Design |
| `vibe-kanban/settings-beta/projects-repositories.mdx` | Project/repo settings | Input for Design |
| `vibe-kanban/settings-beta/remote-projects.mdx` | Remote project settings | Input for Design |

### 2.9 Integrations (5 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/integrations/azure-repos-integration.mdx` | Azure Repos | Input for Architecture |
| `vibe-kanban/integrations/github-integration.mdx` | GitHub integration | Input for Architecture |
| `vibe-kanban/integrations/mcp-server-configuration.mdx` | MCP server setup | Input for Architecture |
| `vibe-kanban/integrations/vibe-kanban-mcp-server.mdx` | VK MCP server | Input for Architecture |
| `vibe-kanban/integrations/vscode-extension.mdx` | VSCode extension | Input for Architecture |

### 2.10 Workspaces (13 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/workspaces/index.mdx` | Workspaces overview | Input for PRD |
| `vibe-kanban/workspaces/creating-workspaces.mdx` | Workspace creation | Input for PRD |
| `vibe-kanban/workspaces/interface.mdx` | Workspace UI | Input for Design |
| `vibe-kanban/workspaces/chat-interface.mdx` | Chat interface | Input for Design |
| `vibe-kanban/workspaces/command-bar.mdx` | Command bar | Input for Design |
| `vibe-kanban/workspaces/changes.mdx` | Change tracking | Input for PRD |
| `vibe-kanban/workspaces/git-operations.mdx` | Git operations | Input for Architecture |
| `vibe-kanban/workspaces/managing-workspaces.mdx` | Workspace management | Input for PRD |
| `vibe-kanban/workspaces/multi-repo-sessions.mdx` | Multi-repo support | Input for PRD |
| `vibe-kanban/workspaces/preview.mdx` | Preview mode | Input for Design |
| `vibe-kanban/workspaces/repositories.mdx` | Repository management | Input for PRD |
| `vibe-kanban/workspaces/sessions.mdx` | Session management | Input for PRD |
| `vibe-kanban/workspaces/slash-commands.mdx` | Slash commands | Input for Design |

### 2.11 Fork History (1 file)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `vibe-kanban/fork-history/MODIFICATION_FORK.md` | Detailed modification log | Historical reference |

---

## 3. Integration & Fork Documentation (14 files)

### 3.1 Fork Information

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `integration/README.md` | Integration docs index | Navigation |
| `integration/FORK.md` | Fork relationship and strategy | Input for Product Brief |
| `integration/FORK-RESTORATION.md` | Fork restoration to v0.1.4 | Historical reference |
| `integration/PRIVACY-VERIFICATION.md` | Privacy audit (Discord/API removal) | Non-functional requirement |
| `integration/integration-architecture.md` | BMAD-VK integration architecture | Input for Architecture |

### 3.2 Build Process (6 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `integration/build-process/BUILD-SYNC-BEHAVIOR.md` | Story sync mechanism | Input for Architecture |
| `integration/build-process/INSTALLER-BUILD-FLOW.md` | Installer build workflow | Input for Architecture |
| `integration/build-process/INSTALLER-VS-DIRECT-BINARY.md` | Binary behavioral differences | Reference |
| `integration/build-process/INSTALLER-FIX-SUMMARY.md` | Installer fixes summary | Reference |
| `integration/build-process/INSTALLER-BINARY-UPDATE-BUG.md` | Binary update bug resolution | Reference |
| `integration/build-process/INSTALLER-TEST-REPORT.md` | Installer test report | Input for Test Strategy |

### 3.3 Testing Reports (3 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `integration/testing-reports/BUILD-WORKFLOW-TEST-REPORT.md` | Build workflow validation | Input for Test Strategy |
| `integration/testing-reports/IMPORT-VERIFICATION.md` | Story import verification | Input for Test Strategy |
| `integration/testing-reports/LINK-VERIFICATION-REPORT.md` | Link verification results | Input for Test Strategy |

---

## 4. BMAD Methodology Documentation (7 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `bmad-methodology/README.md` | BMAD docs index | Navigation |
| `bmad-methodology/methodology/00-BMAD-TEA-MASTER-GUIDE.md` | BMAD-TEA master guide | Framework reference |
| `bmad-methodology/methodology/01-WORKFLOW-PHASES-COMPLETE.md` | Complete workflow phases spec | Framework reference |
| `bmad-methodology/methodology/03-GUIDE-CHOIX-WORKFLOW.md` | Workflow selection guide | Framework reference |
| `bmad-methodology/methodology/POST STORY-EPICS.md` | Post story-epics guide | Framework reference |
| `bmad-methodology/methodology/traceability-matrix.md` | Story traceability matrix | Framework reference |
| `bmad-methodology/tools/WORKFLOW-SYNC-TOOL.md` | Workflow sync analyzer tool | Tool reference |

---

## 5. Plans (2 files)

| File | Description | BMAD Relevance |
|------|-------------|----------------|
| `plans/2026-02-16-multi-platform-installers.md` | Multi-platform installer plan | Input for PRD |
| `plans/2026-02-16-multi-platform-installers-design.md` | Installer design decisions | Input for Architecture |

---

## 6. Documentation Gap Analysis

### 6.1 BMAD-Required Documents (Status)

The BMAD methodology requires the following documents for a complete project lifecycle. The table below shows what exists and what needs to be created.

| BMAD Document | Target Path | Status | Source Material Available |
|---------------|-------------|--------|--------------------------|
| **Product Brief** | `docs/brief/` | MISSING | Yes - README, project-overview, FORK.md |
| **PRD (Product Requirements)** | `docs/prd/` | MISSING | Yes - core-features, workspaces, integrations |
| **Architecture Document** | `docs/architecture/` | PARTIAL | Yes - architecture.md, api-contracts.md, data-models.md, integration-architecture.md |
| **UX/UI Design Document** | `docs/design/` | MISSING | Partial - component-inventory, settings-beta docs, cloud UI docs |
| **Epics & Stories** | `docs/epics-stories-tasks/` | MISSING | Partial - traceability-matrix.md has structure |
| **Test Strategy** | `docs/test/` | PARTIAL | Yes - TESTING-CHECKLIST.md, testing-reports/ |
| **Test Results** | `docs/tests-results/` | PARTIAL | Yes - testing-reports/ directory |

### 6.2 Identified Gaps

1. **No formal Product Brief** -- The project has a detailed README and project overview, but no structured BMAD Product Brief. Source material is readily available.

2. **No formal PRD** -- Core features are well documented in Mintlify `.mdx` files, but they are user-facing documentation, not a structured requirements document. They can serve as input for PRD generation.

3. **Architecture exists but not in BMAD format** -- The existing `architecture.md`, `api-contracts.md`, `data-models.md`, and `integration-architecture.md` provide substantial technical detail. They need to be reconciled into BMAD Architecture format.

4. **No UX/UI Design Document** -- Component inventory and settings docs describe the UI, but there is no formal design document. The 130+ screenshots in `images/` provide visual reference.

5. **No structured Epics & Stories** -- The traceability matrix references stories from `bmad-templates/stories/` but no project-specific epics and stories exist in BMAD format for the brownfield development work.

6. **Test strategy partially exists** -- `TESTING-CHECKLIST.md` covers 6 testing phases and `testing-reports/` has verification reports, but no formal BMAD test strategy document exists.

7. **Cloud features documented but N/A for fork** -- The 13 cloud documentation files describe features that were removed/disabled in this fork (v0.1.4 is local-only). They serve as reference for what the upstream project offers but should be marked as out-of-scope.

### 6.3 Recommendations

1. **Next Step**: Run the BMAD `create-product-brief` workflow using this inventory as input
2. **Priority Documents**: Product Brief -> PRD -> Architecture (BMAD format) -> Epics & Stories
3. **Quick Wins**: The existing architecture docs are thorough and can be adapted to BMAD format with minimal effort
4. **Cloud Docs**: Flag as "upstream reference" rather than active requirements for the fork

---

## 7. Document Origin Map

```
Source                          -> docs/input/ Category
------                             -------------------------
README.md (root)                -> project-root/
DOCUMENTATION.md (root)         -> project-root/
CODE-OF-CONDUCT.md (root)       -> project-root/
RESTORATION-VERIFICATION.md     -> project-root/
docs/build-instructions.md      -> project-root/
docs/docs-vibe-kanban/          -> vibe-kanban/ (81 files)
docs/docs-integration/          -> integration/ (14 files)
docs/docs-bmad-template/        -> bmad-methodology/ (7 files)
docs/plans/                     -> plans/ (2 files)
```

---

*Generated by BMAD import-docs workflow on 2026-02-17*
