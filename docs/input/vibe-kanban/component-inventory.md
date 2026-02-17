# Component Inventory Documentation

## Overview

The bmad-vibe-kanban frontend is built with React and TypeScript, following a Container/View architecture pattern with two parallel design systems:

- **Legacy UI System**: Located in `frontend/src/components/ui/` (shadcn-based)
- **New UI System**: Located in `frontend/src/components/ui-new/` (redesigned components with custom CSS variables)

This document catalogs all frontend components, state management systems, and service layers.

---

## Component Architecture

### Design Pattern: Container/View Separation

The new design system (`ui-new/`) follows a strict separation:

- **Container Components** (`containers/`): Manage state, data fetching, and business logic
- **View Components** (`views/`): Pure presentational components that receive data via props
- **UI Primitives** (`primitives/`): Reusable, atomic UI building blocks

**Example**:
```
FileTreeContainer.tsx (state management)
  -> FileTree.tsx (view logic)
    -> FileTreeNode.tsx (primitive component)
```

---

## Directory Structure

```
frontend/src/components/
├── ui/                    # Legacy shadcn-based UI components (27+ files)
├── ui-new/                # New design system (11 subdirectories)
│   ├── actions/           # Action components (5 files)
│   ├── containers/        # Container components (47+ files)
│   ├── dialogs/           # Dialog components (17 files)
│   ├── hooks/             # Custom React hooks (4 files)
│   ├── primitives/        # Atomic UI components (54+ files)
│   ├── scope/             # Context scope utilities (2 files)
│   ├── terminal/          # Terminal-related components (2 files)
│   ├── types/             # TypeScript type definitions (1 file)
│   └── views/             # View components (31+ files)
├── contexts/              # React Context providers (22 files)
└── [feature dirs]/        # Feature-specific components
```

---

## UI Primitives (Legacy - `components/ui/`)

Shadcn-based reusable UI components:

| Component | Purpose |
|-----------|---------|
| `actions-dropdown.tsx` | Dropdown menu for actions |
| `alert.tsx` | Alert/notification banner |
| `auto-expanding-textarea.tsx` | Self-expanding text input |
| `badge.tsx` | Small status badge |
| `breadcrumb.tsx` | Navigation breadcrumb |
| `button.tsx` | Button component with variants |
| `card.tsx` | Card container |
| `carousel.tsx` | Image/content carousel |
| `checkbox.tsx` | Checkbox input |
| `dialog.tsx` | Modal dialog |
| `dropdown-menu.tsx` | Dropdown menu |
| `input.tsx` | Text input field |
| `json-editor.tsx` | JSON editor widget |
| `label.tsx` | Form label |
| `loader.tsx` | Loading spinner |
| `multi-file-search-textarea.tsx` | Multi-file search input |
| `new-card.tsx` | Enhanced card component |
| `pr-comment-card.tsx` | PR comment display card |
| `progress.tsx` | Progress bar |
| `select.tsx` | Select dropdown |
| `switch.tsx` | Toggle switch |
| `table/` | Table components |
| `textarea.tsx` | Multi-line text input |
| `toggle-group.tsx` | Toggle button group |
| `tooltip.tsx` | Tooltip overlay |
| `wysiwyg/` | WYSIWYG editor components |
| `wysiwyg.tsx` | WYSIWYG editor wrapper |

---

## New Design System (`components/ui-new/`)

### Primitives (`primitives/`)

Atomic, reusable UI components (54+ files):

**Layout & Structure**:
- `Stack.tsx` - Vertical/horizontal stack layout
- `Flex.tsx` - Flexible box layout
- `Grid.tsx` - Grid layout
- `Separator.tsx` - Visual separator line
- `ScrollArea.tsx` - Custom scrollable area

**Form Elements**:
- `Field.tsx` - Form field wrapper
- `Label.tsx` - Form label
- `Input.tsx` - Text input
- `Textarea.tsx` - Multi-line input
- `Select.tsx` - Dropdown select
- `Checkbox.tsx` - Checkbox input
- `Switch.tsx` - Toggle switch
- `RadioGroup.tsx` - Radio button group
- `Combobox.tsx` - Searchable select

**Buttons & Actions**:
- `Button.tsx` - Primary button component
- `IconButton.tsx` - Icon-only button
- `ToggleButton.tsx` - Toggle button
- `ButtonGroup.tsx` - Button group container

**Typography**:
- `Text.tsx` - Text component with variants
- `Heading.tsx` - Heading component
- `Code.tsx` - Inline code display
- `Link.tsx` - Link component

**Feedback**:
- `Badge.tsx` - Status badge
- `Spinner.tsx` - Loading spinner
- `Progress.tsx` - Progress indicator
- `Tooltip.tsx` - Tooltip overlay
- `Toast.tsx` - Toast notification

**Data Display**:
- `Card.tsx` - Card container
- `Table.tsx` - Data table
- `List.tsx` - List container
- `Avatar.tsx` - User avatar
- `Tag.tsx` - Tag/label component

**Navigation**:
- `Tabs.tsx` - Tab navigation
- `Breadcrumb.tsx` - Breadcrumb trail
- `Menu.tsx` - Dropdown menu
- `ContextMenu.tsx` - Right-click menu

**Overlays**:
- `Dialog.tsx` - Modal dialog
- `Popover.tsx` - Popover overlay
- `Sheet.tsx` - Slide-in panel
- `Alert.tsx` - Alert dialog

---

### Container Components (`containers/`)

State-managing components that orchestrate business logic (47+ files):

**Project & Task Management**:
- `CreateModeAddReposSectionContainer.tsx` - Add repositories UI
- `CreateModeReposSectionContainer.tsx` - Repository list UI
- `CreateRepoButtonContainer.tsx` - Repository creation
- `KanbanContainer.tsx` - Kanban board state
- `KanbanDisplaySettingsContainer.tsx` - Kanban settings

**Workspace & Session**:
- `ConversationListContainer.tsx` - Workspace conversation history
- `IssueWorkspacesSectionContainer.tsx` - Workspace list for issues
- `CreateChatBoxContainer.tsx` - Chat input box

**Git & Version Control**:
- `ChangesPanelContainer.tsx` - Git changes panel
- `GitPanelContainer.tsx` - Git operations panel
- `FileTreeContainer.tsx` - File tree browser
- `BrowseRepoButtonContainer.tsx` - Repository browser

**UI Components**:
- `AppBarUserPopoverContainer.tsx` - User menu popover
- `ColorPickerContainer.tsx` - Color picker widget
- `ContextBarContainer.tsx` - Context toolbar

**Comments & Collaboration**:
- `CommentWidgetLine.tsx` - Inline comment widget
- `GitHubCommentRenderer.tsx` - GitHub markdown comment renderer
- `IssueCommentsSectionContainer.tsx` - Issue comments UI
- `IssueSubIssuesSectionContainer.tsx` - Sub-issues list

**Utilities**:
- `CopyButton.tsx` - Copy-to-clipboard button

---

### View Components (`views/`)

Pure presentational components (31+ files):

**Project Views**:
- `KanbanBoard.tsx` - Kanban board view
- `KanbanCardContent.tsx` - Kanban card content
- `KanbanFilterBar.tsx` - Filter controls
- `KanbanIssuePanel.tsx` - Issue details panel

**Issue Views**:
- `IssueListView.tsx` - Issue list view
- `IssueListSection.tsx` - Issue list section
- `IssueListRow.tsx` - Single issue row
- `IssuePropertyRow.tsx` - Issue property display
- `IssueTagsRow.tsx` - Issue tags display
- `IssueCommentsSection.tsx` - Comments section view
- `IssueSubIssuesSection.tsx` - Sub-issues section
- `IssueWorkspaceCard.tsx` - Workspace card in issue
- `IssueWorkspacesSection.tsx` - Workspaces section

**File & Git Views**:
- `FileTree.tsx` - File tree view
- `FileTreeNode.tsx` - File tree node
- `FileTreePlaceholder.tsx` - Empty state placeholder
- `FileTreeSearchBar.tsx` - File search bar
- `GitPanel.tsx` - Git operations view
- `ChangesPanel.tsx` - Changes panel view

**Migration & Onboarding**:
- `MigrateChooseProjects.tsx` - Project selection for migration

---

### Dialog Components (`dialogs/`)

Modal dialogs for user interactions (17+ files):

- `CreateProjectDialog.tsx` - New project creation
- `CreateTaskDialog.tsx` - New task creation
- `SettingsDialog.tsx` - Application settings
- `ConfirmDialog.tsx` - Confirmation prompts
- `ImageUploadDialog.tsx` - Image upload
- `MergeDialog.tsx` - Merge confirmation
- `RebaseDialog.tsx` - Rebase options
- And 10+ more specialized dialogs

---

### Action Components (`actions/`)

Action-specific components (5 files):

- Action buttons
- Action menus
- Quick actions toolbar

---

### Terminal Components (`terminal/`)

Terminal-related UI (2 files):

- Terminal emulator component
- Terminal controls

---

### Custom Hooks (`hooks/`)

Reusable React hooks (4+ files):

- State management hooks
- Effect hooks
- Event handler hooks

---

## State Management

### Zustand Stores (`stores/`)

Global state management using Zustand (5 stores):

| Store | File | Purpose |
|-------|------|---------|
| **DiffViewStore** | `useDiffViewStore.ts` | Git diff view state (side-by-side, unified, etc.) |
| **ExpandableStore** | `useExpandableStore.ts` | Collapsible panel state |
| **OrganizationStore** | `useOrganizationStore.ts` | Current organization context |
| **TaskDetailsUiStore** | `useTaskDetailsUiStore.ts` | Task detail panel UI state |
| **UiPreferencesStore** | `useUiPreferencesStore.ts` | User UI preferences (theme, layout, 18KB file) |

**Example Store Structure**:
```typescript
// useDiffViewStore.ts
interface DiffViewStore {
  viewMode: 'split' | 'unified';
  showWhitespace: boolean;
  setViewMode: (mode: 'split' | 'unified') => void;
  toggleWhitespace: () => void;
}
```

---

### React Contexts (`contexts/`)

Context providers for component trees (22+ contexts):

**Core Contexts**:
- `ProjectContext.tsx` - Current project state
- `WorkspaceContext.tsx` - Current workspace state (8KB file)
- `ActionsContext.tsx` - Action dispatcher (11KB file)

**UI State Contexts**:
- `ClickedElementsProvider.tsx` - Click tracking (11KB file)
- `CreateModeContext.tsx` - Create mode state
- `ChangesViewContext.tsx` - Changes view state
- `LogsPanelContext.tsx` - Logs panel state
- `ProcessSelectionContext.tsx` - Process selection state

**Feature Contexts**:
- `ExecutionProcessesContext.tsx` - Execution process management
- `GitOperationsContext.tsx` - Git operation state
- `SearchContext.tsx` - Search functionality state
- `MessageEditContext.tsx` - Message editing state
- `EntriesContext.tsx` - Entries management

**Terminal Context**:
- `TerminalContext.tsx` - Terminal emulator state (14KB file)

**Approval System**:
- `ApprovalFeedbackContext.tsx` - Approval feedback UI
- `ApprovalFormContext.tsx` - Approval form state

**Review & Sync**:
- `ReviewProvider.tsx` - Code review state
- `RetryUiContext.tsx` - Retry UI state
- `SyncErrorContext.tsx` - Sync error handling

**Utilities**:
- `PortalContainerContext.tsx` - Portal mounting point
- `TabNavigationContext.tsx` - Tab navigation state

**Remote Contexts** (`contexts/remote/`):
- Remote-specific context providers for cloud features

---

## Service Layer (`lib/api.ts`)

The frontend uses a centralized API module that organizes HTTP requests into namespaces (13+ namespaces):

### API Namespace Structure

Based on the imports in `/private/var/folders/nn/0dh5rvfj2s97hwf3p6ctb0zw0000gn/T/vibe-kanban/worktrees/436c-2-analyze-existi/bmad-vibe-kanban/frontend/src/lib/api.ts`:

**Core Resources**:
1. **Projects API**
   - `createProject(data: CreateProject): Promise<Project>`
   - `updateProject(id: UUID, data: UpdateProject): Promise<Project>`
   - `deleteProject(id: UUID): Promise<void>`
   - `listProjects(): Promise<Project[]>`
   - `getProject(id: UUID): Promise<Project>`

2. **Tasks API**
   - `createTask(data: CreateTask): Promise<Task>`
   - `updateTask(id: UUID, data: UpdateTask): Promise<Task>`
   - `deleteTask(id: UUID): Promise<void>`
   - `listTasks(projectId: UUID): Promise<TaskWithAttemptStatus[]>`
   - `getTaskRelationships(taskId: UUID, workspaceId: UUID): Promise<TaskRelationships>`

3. **Workspaces API** (formerly task-attempts)
   - `createWorkspace(data: CreateTaskAttemptBody): Promise<Workspace>`
   - `updateWorkspace(id: UUID, data: UpdateWorkspace): Promise<Workspace>`
   - `deleteWorkspace(id: UUID): Promise<void>`
   - `listWorkspaces(taskId?: UUID): Promise<WorkspaceWithSession[]>`
   - `startWorkspace(id: UUID): Promise<void>`
   - `followUpWorkspace(id: UUID, data: CreateFollowUpAttempt): Promise<void>`
   - `reviewWorkspace(id: UUID, data: StartReviewRequest): Promise<void>`
   - `mergeWorkspace(id: UUID, data: MergeTaskAttemptRequest): Promise<void>`
   - `archiveWorkspace(id: UUID): Promise<void>`
   - `renameWorkspace(id: UUID, data: RenameBranchRequest): Promise<void>`

4. **Sessions API**
   - `getLatestSession(workspaceId: UUID): Promise<Session>`
   - `createSession(data: CreateSession): Promise<Session>`
   - `forkSession(sessionId: UUID): Promise<Session>`

5. **Execution Processes API**
   - `listExecutionProcesses(sessionId: UUID): Promise<ExecutionProcess[]>`
   - `getExecutionProcess(id: UUID): Promise<ExecutionProcess>`
   - `killExecutionProcess(id: UUID): Promise<void>`
   - `streamExecutionProcess(id: UUID): EventSource` (SSE)
   - `streamDiff(id: UUID): EventSource` (SSE)

6. **Repositories API**
   - `listRepos(): Promise<Repo[]>`
   - `getRepo(id: UUID): Promise<Repo>`
   - `updateRepo(id: UUID, data: UpdateRepo): Promise<Repo>`
   - `discoverRepos(path: string): Promise<Repo[]>`

7. **Tags API**
   - `createTag(data: CreateTag): Promise<Tag>`
   - `updateTag(id: UUID, data: UpdateTag): Promise<Tag>`
   - `deleteTag(id: UUID): Promise<void>`
   - `listTags(params: TagSearchParams): Promise<Tag[]>`

8. **Images API**
   - `uploadImage(file: File): Promise<ImageResponse>`
   - `getImage(id: UUID): Promise<ImageResponse>`

9. **Config API**
   - `getConfig(): Promise<Config>`
   - `updateConfig(data: Partial<Config>): Promise<Config>`
   - `getExecutorProfiles(): Promise<ExecutorProfileId[]>`
   - `getLoginStatus(): Promise<StatusResponse>`

10. **Filesystem API**
    - `listDirectory(path: string): Promise<DirectoryListResponse>`
    - `readFile(path: string): Promise<string>`
    - `writeFile(path: string, content: string): Promise<void>`
    - `discoverRepos(path: string): Promise<Repo[]>`

11. **Search API**
    - `searchFiles(query: string, mode: SearchMode, repoIds: UUID[]): Promise<SearchResult[]>`

12. **Scratch API** (Draft storage)
    - `getScratch(type: ScratchType, id: UUID): Promise<Scratch>`
    - `createScratch(type: ScratchType, id: UUID, data: CreateScratch): Promise<Scratch>`
    - `updateScratch(type: ScratchType, id: UUID, data: UpdateScratch): Promise<Scratch>`
    - `deleteScratch(type: ScratchType, id: UUID): Promise<void>`
    - `streamScratchWs(type: ScratchType, id: UUID): WebSocket`

13. **Organizations API** (Remote)
    - `listOrganizations(): Promise<ListOrganizationsResponse>`
    - `createOrganization(data: CreateOrganizationRequest): Promise<CreateOrganizationResponse>`
    - `listMembers(orgId: UUID): Promise<ListMembersResponse>`
    - `createInvitation(data: CreateInvitationRequest): Promise<CreateInvitationResponse>`
    - `revokeInvitation(data: RevokeInvitationRequest): Promise<void>`
    - `updateMemberRole(data: UpdateMemberRoleRequest): Promise<UpdateMemberRoleResponse>`

### API Communication Patterns

- **REST API**: Standard CRUD operations via fetch
- **Server-Sent Events (SSE)**: Real-time log streaming, diff streaming, event streams
- **WebSocket**: Terminal PTY sessions, scratch pad streaming
- **Type Safety**: Full TypeScript types via `shared/types` and ts-rs codegen

---

## Design System Styling

### New Design System (`ui-new/`)

**CSS Variables** (defined in `src/styles/new/index.css`):
- Scoped to `.new-design` class
- Custom color tokens: `text-high`, `text-normal`, `text-low`
- Background tokens: `bg-primary`, `bg-secondary`, `bg-panel`
- Brand color: `hsl(25 82% 54%)` (orange)

**Typography**:
- Font families: IBM Plex Sans (default), IBM Plex Mono (code)
- Font sizes: `text-xs` (8px) to `text-xl` (16px), default `text-base` (12px)

**Spacing**:
- Custom tokens: `p-half` (6px), `p-base` (12px), `p-double` (24px)

**Border Radius**:
- Default: `--radius: 0.125rem` (small)

**Focus States**:
- Focus rings use `ring-brand` (orange), inset by default

**Tailwind Config**:
- Custom config in `tailwind.new.config.js`

---

## Component File Naming Conventions

- **ui-new/ files**: Must be PascalCase (e.g., `Field.tsx`, `Label.tsx`)
- **Legacy ui/ files**: May use kebab-case (e.g., `actions-dropdown.tsx`)
- **Container files**: Suffix with `Container.tsx`
- **View files**: No special suffix (e.g., `KanbanBoard.tsx`)

---

## Key Frontend Features

### 1. Multi-Repo Workspace Support
- File tree displays all repos in workspace
- Git operations per-repo
- Diff viewing per-repo

### 2. Real-time Updates
- Server-Sent Events for execution process logs
- WebSocket for terminal sessions
- Event streaming via MsgStore

### 3. Approval System
- Tool call approval UI
- Approval feedback display
- Approval form context

### 4. Terminal Emulator
- PTY via WebSocket
- Terminal context (14KB state management)
- Terminal controls

### 5. Code Review
- Review provider context
- Diff viewing (side-by-side, unified)
- PR comment rendering

### 6. Image Attachments
- Upload dialog
- Image storage with deduplication
- Task-image associations

### 7. Migration UI
- Project selection
- Migration progress
- Sync error handling

---

## Component Count Summary

| Category | Count | Location |
|----------|-------|----------|
| Legacy UI Components | 27+ | `components/ui/` |
| New UI Primitives | 54+ | `components/ui-new/primitives/` |
| Container Components | 47+ | `components/ui-new/containers/` |
| View Components | 31+ | `components/ui-new/views/` |
| Dialog Components | 17+ | `components/ui-new/dialogs/` |
| Zustand Stores | 5 | `stores/` |
| React Contexts | 22+ | `contexts/` |
| API Namespaces | 13+ | `lib/api.ts` |
| **Total Component Files** | **220+** | |

---

*Generated by BMAD Document Project Workflow v1.2.0 (Deep Scan)*
