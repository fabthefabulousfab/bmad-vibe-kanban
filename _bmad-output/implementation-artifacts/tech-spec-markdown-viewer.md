---
title: 'Markdown Documentation Viewer'
slug: 'markdown-viewer'
created: '2026-03-12'
status: 'ready-for-dev'
stepsCompleted: [1, 2, 3, 4]
tech_stack: ['React 18', 'TypeScript 5.9', 'Axum 0.8', 'Rust nightly', 'TailwindCSS 3.4', 'Phosphor Icons', 'react-markdown', 'remark-gfm', 'rehype-highlight']
files_to_modify:
  - 'crates/server/src/routes/mod.rs'
  - 'crates/server/src/routes/filesystem.rs'
  - 'crates/services/src/services/filesystem.rs'
  - 'crates/git/src/lib.rs'
  - 'frontend/src/App.tsx'
  - 'frontend/src/lib/api.ts'
  - 'frontend/src/components/ui-new/actions/index.ts'
  - 'frontend/src/components/ui-new/primitives/ContextBar.tsx'
  - 'shared/types.ts'
code_patterns:
  - 'Container/View pattern (enforced by ESLint)'
  - 'ActionDefinition system for ContextBar buttons'
  - 'Deployment trait for backend services'
  - 'ApiResponse<T> wrapper for all API responses'
  - 'Phosphor Icons with size-icon-* classes'
  - 'NiceModal for dialogs'
test_patterns:
  - 'Vitest for frontend unit tests'
  - 'cargo test for backend'
  - 'Playwright for E2E tests'
---

# Tech-Spec: Markdown Documentation Viewer

**Created:** 2026-03-12

## Overview

### Problem Statement

Developers working in the Vibe Kanban workspace need a way to browse, read, and preview Markdown documentation files (.md) directly within the application. Currently, the only file access is through the "Open in IDE" button which launches an external editor. There is no integrated documentation viewer that allows reading and previewing markdown files without leaving the application.

### Solution

Add a new "MD" icon button to the ContextBar (next to the existing IDE icon) that opens a dedicated Markdown Documentation Viewer screen. This screen provides:

1. **Left sidebar**: A file tree showing only directories and `.md` files from the workspace repository
2. **Branch selector**: A dropdown above the file tree to switch between git branches
3. **Split content area**: Left pane is an **editable** raw markdown editor with a **Save** button, right pane shows live rendered HTML preview with **synchronized scrolling** between both panes
4. **Git action bar**: A dropdown with git actions (Commit & Push, Merge to Review, Merge to Stable) and a "DO!" button to execute

### Scope

**In Scope:**
- New ContextBar action with "MD" icon to open the viewer
- New route `/workspaces/:workspaceId/markdown` for the viewer page
- File tree component filtered to `.md` files and their parent directories
- Branch selector dropdown using existing `repoApi.getBranches()` API
- Split-pane view: raw markdown (left) + rendered HTML preview (right) with synchronized scrolling
- New backend API endpoints: file tree (filtered), file content reading, branch checkout
- Git action dropdown with: Commit & Push, Merge to Review branch, Merge to Stable branch
- "DO!" button to execute the selected git action
- Keyboard navigation in file tree
- Right-click context menu on file tree items with: Rename, Delete, New File, New Folder
- Inline rename input field in the file tree
- Confirmation dialog for delete operations
- Backend API endpoints for file/directory CRUD (create, rename, delete)

**Out of Scope:**
- Rich text / WYSIWYG editing (the editor is plain text / raw markdown only)
- Drag-and-drop file reordering or moving files between directories
- Conflict resolution UI (uses existing ResolveConflictsDialog)
- Multiple repository support (uses primary repo of workspace)
- File search within the markdown viewer
- Syntax highlighting in the markdown editor pane (plain monospace textarea)
- Line-based scroll mapping (uses simpler proportional scroll synchronization)

## Context for Development

### Codebase Patterns

**Frontend Container/View Pattern (ENFORCED BY ESLINT):**
- Containers: fetch data, manage state, handle mutations
- Views: STATELESS - receive all data via props
- Views CANNOT use: useState, useEffect, useQuery, etc.
- Containers CANNOT have optional props

**Action System (ContextBar):**
- Actions defined in `frontend/src/components/ui-new/actions/index.ts`
- Each action has: id, label, icon, requiresTarget, execute, isVisible
- Special icon types: `'ide-icon'`, `'copy-icon'` - rendered differently in ContextBar
- New special icon type `'md-icon'` needed for the markdown viewer button
- ContextBar groups: `primary` (top) and `secondary` (bottom), defined in `ContextBarActionGroups`

**Backend Deployment Trait:**
- All services accessed via `Deployment` trait
- New service methods require: trait method + LocalDeployment implementation
- Route handlers generic over `D: Deployment`

**API Response Format:**
- All responses wrapped in `ApiResponse<T>` with `success: boolean`, `data?: T`, `error?: string`

### Files to Reference

| File | Purpose |
| ---- | ------- |
| `frontend/src/components/ui-new/actions/index.ts` | Action definitions, ContextBar groups, ActionDefinition types |
| `frontend/src/components/ui-new/primitives/ContextBar.tsx` | ContextBar component rendering actions, special icon handling |
| `frontend/src/components/ide/IdeIcon.tsx` | IdeIcon pattern - reference for creating MdIcon |
| `frontend/src/components/ide/OpenInIdeButton.tsx` | Button pattern for the MD button |
| `frontend/src/App.tsx` | Route definitions - add new markdown viewer route |
| `frontend/src/lib/api.ts` | API client - existing `repoApi.getBranches()`, `attemptsApi.getRepos()` |
| `frontend/src/pages/ui-new/VSCodeWorkspacePage.tsx` | Reference for page structure with workspace context |
| `crates/server/src/routes/filesystem.rs` | Existing filesystem routes - extend with file content + filtered tree |
| `crates/server/src/routes/mod.rs` | Router merging - add new routes |
| `crates/services/src/services/filesystem.rs` | Filesystem service - add file content reading and filtered tree |
| `crates/git/src/lib.rs` | GitService - has `read_file_to_string`, branch operations |
| `shared/types.ts` | Shared TypeScript types - add new types for file tree and content |
| `frontend/src/components/ui-new/containers/ContextBarContainer.tsx` | How ContextBar is wired with actions |

### Technical Decisions

1. **Markdown Rendering**: Use `react-markdown` with `remark-gfm` (GitHub Flavored Markdown) and `rehype-highlight` for code block syntax highlighting. These are standard, well-maintained libraries.

2. **File Tree Filtering**: Filter on the backend for efficiency - the API endpoint returns only `.md` files and their parent directory structure. This avoids sending the entire file tree to the frontend.

3. **Branch Switching**: Reuse existing `repoApi.getBranches(repoId)` API. For checkout, add a new endpoint that calls `GitService` to switch branches in the worktree.

4. **Split Pane Layout**: Use a CSS grid with `grid-template-columns: 1fr 1fr` for the content area. No third-party split-pane library needed - keep it simple.

5. **Git Actions**: The "Merge to Review" and "Merge to Stable" actions will use the existing merge infrastructure (`attemptsApi.merge()`) with target branch overrides. Commit & Push uses existing `attemptsApi.push()` after a commit via a new endpoint.

6. **Navigation**: The MD viewer opens as a full page at `/workspaces/:workspaceId/markdown`. The user can navigate back to the workspace using browser back or a back button in the header.

7. **Special Icon**: Add `'md-icon'` as a new `SpecialIconType`. The icon will be a simple "MD" text badge styled consistently with the existing context bar icons.

8. **File Tree Context Menu**: Use Radix UI `ContextMenu` (already in the project's dependency tree via Radix primitives) for the right-click menu. The menu adapts its items based on the target: files show "Rename" and "Delete"; directories show "New File", "New Folder", "Rename", and "Delete". Rename uses an inline `<input>` that replaces the filename text. Delete shows a confirmation dialog (reusing the existing `ConfirmDialog` pattern). New File/Folder creates an inline input at the target location for entering the name.

9. **File Tree CRUD Security**: All create/rename/delete operations are restricted to paths within the workspace worktree. Rename and create operations for files enforce the `.md` extension. Delete on a directory requires it to be empty (or only contain `.md` files). All paths are validated with `canonicalize()` to prevent traversal.

10. **Synchronized Scrolling**: Use proportional scroll synchronization between the editor textarea and preview pane. When either pane is scrolled, the other pane scrolls to the same percentage position: `targetScrollTop = (sourceScrollTop / sourceMaxScroll) * targetMaxScroll`. Use a `requestAnimationFrame` guard and a `scrollSource` ref to prevent infinite feedback loops. The sync is bidirectional: scrolling either pane updates the other.

## Implementation Plan

### Tasks

**Phase 1: Backend - File Tree and Content APIs**

**Task 1.1: Add filtered markdown file tree endpoint**
- File: `crates/services/src/services/filesystem.rs`
- Action: Add method `list_markdown_files(path: Option<String>) -> Result<Vec<DirectoryEntry>>` that walks the directory recursively and returns only `.md` files and their parent directories in a tree structure.
- Add `FileTreeEntry` struct with fields: `name: String`, `path: String`, `is_directory: bool`, `children: Vec<FileTreeEntry>`
- Filter: include only entries where `name.ends_with(".md")` or directory contains at least one `.md` file (recursively)

**Task 1.2: Add file content read/write endpoints**
- File: `crates/services/src/services/filesystem.rs`
- Action: Add method `read_file_content(path: String) -> Result<String>` that reads a file's content as UTF-8 string.
- Action: Add method `write_file_content(path: String, content: String) -> Result<()>` that writes content back to a `.md` file.
- Validation: path must be within a known workspace/repo directory (security), file must exist, file must end with `.md`
- Error handling: `FileNotFound`, `PathTraversal`, `NotMarkdownFile`, `Io`

**Task 1.2b: Add file/directory CRUD operations**
- File: `crates/services/src/services/filesystem.rs`
- Action: Add methods:
  ```rust
  /// Creates a new empty .md file at the given path
  fn create_file(base_path: &str, relative_path: &str) -> Result<()>
  // Validation: path within workspace, must end with .md, parent dir must exist

  /// Creates a new directory at the given path
  fn create_directory(base_path: &str, relative_path: &str) -> Result<()>
  // Validation: path within workspace, parent dir must exist

  /// Renames a file or directory
  fn rename_entry(base_path: &str, old_path: &str, new_name: &str) -> Result<String>
  // Validation: path within workspace, new name valid (no slashes, no traversal)
  // For files: new_name must end with .md
  // Returns: new full relative path

  /// Deletes a file or empty directory
  fn delete_entry(base_path: &str, relative_path: &str) -> Result<()>
  // Validation: path within workspace, if directory must be empty
  // If file is currently selected in editor, clear selection
  ```
- Error handling: `PathTraversal`, `NotFound`, `DirectoryNotEmpty`, `InvalidName`, `NotMarkdownFile`
- File: `crates/server/src/routes/filesystem.rs`
- Action: Add routes:
  - `POST /api/filesystem/create-file` with body `{ base_path, relative_path }` -> creates empty .md file
  - `POST /api/filesystem/create-directory` with body `{ base_path, relative_path }` -> creates directory
  - `POST /api/filesystem/rename` with body `{ base_path, old_path, new_name }` -> renames file/dir, returns new path
  - `DELETE /api/filesystem/entry` with body `{ base_path, relative_path }` -> deletes file or empty dir

**Task 1.3: Add git checkout branch endpoint**
- File: `crates/git/src/lib.rs` (or relevant git service)
- Action: Add method to checkout a branch in a worktree. Use `git2::Repository::set_head()` + checkout.
- File: `crates/services/src/services/git_service.rs` or equivalent
- Wrap git2 call in service method

**Task 1.4: Add commit endpoint for markdown files**
- File: `crates/server/src/routes/task_attempts.rs` or new route file
- Action: Add POST endpoint `/api/task-attempts/:id/commit` that stages all changes, creates a commit with a provided message, and optionally pushes.
- Reuse existing `GitCli.add_all()` and `GitCli.commit()` patterns.

**Task 1.5: Register new routes**
- File: `crates/server/src/routes/filesystem.rs`
- Action: Add routes:
  - `GET /api/filesystem/markdown-tree?path=<workspace_path>` -> returns filtered file tree
  - `GET /api/filesystem/file-content?path=<file_path>` -> returns file content as string
  - `PUT /api/filesystem/file-content` with body `{ path, content }` -> writes file content, returns success
- File: `crates/server/src/routes/task_attempts.rs`
- Action: Add routes:
  - `POST /api/task-attempts/:id/checkout-branch` with body `{ repo_id, branch_name }`
  - `POST /api/task-attempts/:id/commit-and-push` with body `{ repo_id, message }`
  - `POST /api/task-attempts/:id/merge-to-branch` with body `{ repo_id, target_branch }`
- File: `crates/server/src/routes/mod.rs`
- Action: Ensure new routes are merged into the router

**Task 1.6: Add Rust types with ts-rs derive**
- File: `crates/db/src/models/` or `crates/utils/src/`
- Action: Add types for API request/response:
  ```rust
  #[derive(Serialize, Deserialize, TS)]
  pub struct FileTreeEntry {
      pub name: String,
      pub path: String,
      pub is_directory: bool,
      pub children: Vec<FileTreeEntry>,
  }

  #[derive(Serialize, Deserialize, TS)]
  pub struct FileContentResponse {
      pub content: String,
      pub path: String,
  }

  #[derive(Deserialize)]
  pub struct CheckoutBranchRequest {
      pub repo_id: String,
      pub branch_name: String,
  }

  #[derive(Deserialize)]
  pub struct CommitAndPushRequest {
      pub repo_id: String,
      pub message: String,
  }

  #[derive(Deserialize)]
  pub struct MergeToBranchRequest {
      pub repo_id: String,
      pub target_branch: String,
  }
  #[derive(Deserialize)]
  pub struct CreateFileRequest {
      pub base_path: String,
      pub relative_path: String,
  }

  #[derive(Deserialize)]
  pub struct CreateDirectoryRequest {
      pub base_path: String,
      pub relative_path: String,
  }

  #[derive(Deserialize)]
  pub struct RenameEntryRequest {
      pub base_path: String,
      pub old_path: String,
      pub new_name: String,
  }

  #[derive(Serialize, Deserialize, TS)]
  pub struct RenameEntryResponse {
      pub new_path: String,
  }

  #[derive(Deserialize)]
  pub struct DeleteEntryRequest {
      pub base_path: String,
      pub relative_path: String,
  }
  ```
- Run `cargo run --bin generate_types` to generate TypeScript types

**Phase 2: Frontend - API Client and Types**

**Task 2.1: Add API client methods**
- File: `frontend/src/lib/api.ts`
- Action: Add to `attemptsApi`:
  ```typescript
  getMarkdownTree: async (attemptId: string, repoId: string): Promise<FileTreeEntry[]>
  getFileContent: async (attemptId: string, filePath: string): Promise<FileContentResponse>
  saveFileContent: async (attemptId: string, data: { path: string, content: string }): Promise<void>
  checkoutBranch: async (attemptId: string, data: CheckoutBranchRequest): Promise<void>
  commitAndPush: async (attemptId: string, data: CommitAndPushRequest): Promise<void>
  mergeToBranch: async (attemptId: string, data: MergeToBranchRequest): Promise<void>
  createFile: async (data: CreateFileRequest): Promise<void>
  createDirectory: async (data: CreateDirectoryRequest): Promise<void>
  renameEntry: async (data: RenameEntryRequest): Promise<RenameEntryResponse>
  deleteEntry: async (data: DeleteEntryRequest): Promise<void>
  ```

**Task 2.2: Add React Query hooks**
- File: `frontend/src/hooks/useMarkdownViewer.ts` (NEW)
- Action: Create hooks:
  - `useMarkdownTree(attemptId, repoId)` - fetches and caches the file tree
  - `useFileContent(attemptId, filePath)` - fetches file content with caching
  - `useBranches(repoId)` - wraps existing `repoApi.getBranches()`
  - `useSaveFileContent()` - mutation hook for saving edited file
  - `useSyncScroll(editorRef, previewRef)` - synchronizes scroll position between editor and preview panes using proportional mapping. Returns `{ onEditorScroll, onPreviewScroll }` handlers. Uses a `scrollSource` ref (`'editor' | 'preview' | null`) and `requestAnimationFrame` to prevent infinite loops.
  - `useCreateFile()` - mutation hook for creating a new .md file; on success invalidates markdown tree query
  - `useCreateDirectory()` - mutation hook for creating a new directory; on success invalidates markdown tree query
  - `useRenameEntry()` - mutation hook for renaming a file/dir; on success invalidates markdown tree query and file content cache
  - `useDeleteEntry()` - mutation hook for deleting a file/dir; on success invalidates markdown tree query, clears selection if deleted file was selected
  - `useCheckoutBranch()` - mutation hook for branch checkout
  - `useCommitAndPush()` - mutation hook
  - `useMergeToBranch()` - mutation hook

**Phase 3: Frontend - Components**

**Task 3.1: Create MdIcon component**
- File: `frontend/src/components/markdown/MdIcon.tsx` (NEW)
- Action: Create a simple icon component that renders "MD" text as a styled badge, matching the size pattern of IdeIcon.
  ```tsx
  export function MdIcon({ className = 'h-4 w-4' }: { className?: string }) {
    return (
      <span className={cn('inline-flex items-center justify-center font-bold text-[9px] leading-none', className)}>
        MD
      </span>
    );
  }
  ```

**Task 3.2: Create MarkdownFileTree view component**
- File: `frontend/src/components/markdown/views/MarkdownFileTreeView.tsx` (NEW)
- Action: STATELESS view component receiving props:
  ```typescript
  interface MarkdownFileTreeViewProps {
    entries: FileTreeEntry[];
    selectedFilePath: string | null;
    expandedDirs: Record<string, boolean>;
    renamingPath: string | null;          // path currently being renamed (inline input)
    renameValue: string;                  // current value in rename input
    creatingAt: { parentPath: string; type: 'file' | 'directory' } | null; // inline input for new item
    createValue: string;                  // current value in create input
    onSelectFile: (path: string) => void;
    onToggleDir: (path: string) => void;
    onContextMenuAction: (action: TreeContextAction, targetPath: string, isDirectory: boolean) => void;
    onRenameChange: (value: string) => void;
    onRenameSubmit: () => void;
    onRenameCancel: () => void;
    onCreateChange: (value: string) => void;
    onCreateSubmit: () => void;
    onCreateCancel: () => void;
  }

  type TreeContextAction = 'rename' | 'delete' | 'new-file' | 'new-folder';
  ```
- Renders a recursive tree with folder/file icons (Phosphor: `FolderSimple`, `FileText`)
- Highlights selected file
- Keyboard navigation: Arrow keys to navigate, Enter to select
- **Right-click context menu** using Radix `ContextMenu`:
  - On a **file**: shows "Rename" and "Delete"
  - On a **directory**: shows "New File", "New Folder", "Rename", "Delete"
  - On **empty area** (below all items): shows "New File", "New Folder" (at root)
- **Inline rename**: When `renamingPath` is set, that tree item's label becomes an `<input>` pre-filled with the current name. Enter confirms, Escape cancels. Input auto-focuses.
- **Inline create**: When `creatingAt` is set, a new temporary row appears inside the target directory with an `<input>`. Enter confirms, Escape cancels. For files, `.md` extension is auto-appended if not present.

**Task 3.3: Create BranchSelector view component**
- File: `frontend/src/components/markdown/views/BranchSelectorView.tsx` (NEW)
- Action: STATELESS view with props:
  ```typescript
  interface BranchSelectorViewProps {
    branches: GitBranch[];
    currentBranch: string;
    onSelectBranch: (branchName: string) => void;
    isLoading: boolean;
  }
  ```
- Renders a `<select>` dropdown styled with Tailwind, showing branch names
- Current branch shown as selected

**Task 3.4: Create GitActionBar view component**
- File: `frontend/src/components/markdown/views/GitActionBarView.tsx` (NEW)
- Action: STATELESS view with props:
  ```typescript
  type GitAction = 'commit-push' | 'merge-review' | 'merge-stable';
  interface GitActionBarViewProps {
    selectedAction: GitAction;
    onSelectAction: (action: GitAction) => void;
    onExecute: () => void;
    isExecuting: boolean;
  }
  ```
- Renders: `<select>` dropdown with 3 options + "DO!" button
- Options: "Commit & Push", "Merge to Review", "Merge to Stable"
- "DO!" button disabled while executing, shows spinner

**Task 3.5: Create MarkdownEditorView component**
- File: `frontend/src/components/markdown/views/MarkdownEditorView.tsx` (NEW)
- Action: STATELESS view providing an **editable** `<textarea>` for raw markdown with a Save button:
  ```typescript
  interface MarkdownEditorViewProps {
    content: string;
    filePath: string;
    hasUnsavedChanges: boolean;
    isSaving: boolean;
    onContentChange: (newContent: string) => void;
    onSave: () => void;
    editorRef: React.RefObject<HTMLTextAreaElement>;
    onScroll: () => void;
  }
  ```
- Uses IBM Plex Mono font (`font-ibm-plex-mono`) matching the design system
- `<textarea>` fills the pane, styled with `bg-secondary/20`, `text-normal`, monospace
- Pane header shows file name + a **Save** button (Phosphor `FloppyDisk` icon)
- Save button uses brand color (`bg-brand text-on-brand`) when there are unsaved changes, disabled/dimmed otherwise
- Keyboard shortcut: Ctrl+S / Cmd+S triggers save
- Unsaved changes indicator: dot or asterisk next to file name in header

**Task 3.6: Create MarkdownPreviewView component**
- File: `frontend/src/components/markdown/views/MarkdownPreviewView.tsx` (NEW)
- Action: STATELESS view rendering markdown as HTML:
  ```typescript
  interface MarkdownPreviewViewProps {
    content: string;
    previewRef: React.RefObject<HTMLDivElement>;
    onScroll: () => void;
  }
  ```
- Uses `react-markdown` with `remark-gfm` and `rehype-highlight`
- Styled with Tailwind prose classes (`prose prose-sm dark:prose-invert`)

**Task 3.7: Create MarkdownViewerContainer**
- File: `frontend/src/components/markdown/containers/MarkdownViewerContainer.tsx` (NEW)
- Action: Container component that:
  - Gets `workspaceId` from route params
  - Fetches repos via `attemptsApi.getRepos(workspaceId)` to get primary repo
  - Uses `useMarkdownTree` hook to fetch file tree
  - Uses `useBranches` hook for branch list
  - Manages state: `selectedFilePath`, `selectedBranch`, `expandedDirs`, `selectedAction`
  - Manages context menu state: `renamingPath`, `renameValue`, `creatingAt`, `createValue`
  - Uses `useFileContent` hook when a file is selected
  - Uses `useSyncScroll(editorRef, previewRef)` to synchronize scroll between editor and preview
  - Uses `useCreateFile()`, `useCreateDirectory()`, `useRenameEntry()`, `useDeleteEntry()` mutation hooks
  - Handles `onContextMenuAction`: dispatches to rename (sets `renamingPath`), delete (shows ConfirmDialog), new-file/new-folder (sets `creatingAt`)
  - Handles rename submit: calls `useRenameEntry.mutate()`, updates `selectedFilePath` if renamed file was selected
  - Handles create submit: calls `useCreateFile.mutate()` or `useCreateDirectory.mutate()`, auto-selects new file
  - Handles delete confirm: calls `useDeleteEntry.mutate()`, clears selection if deleted file was selected
  - Handles git action execution (commit-push, merge-review, merge-stable)
  - Composes all view components into the full layout

**Task 3.8: Create MarkdownViewerPage**
- File: `frontend/src/pages/ui-new/MarkdownViewerPage.tsx` (NEW)
- Action: Page component that wraps MarkdownViewerContainer with necessary providers:
  ```tsx
  export function MarkdownViewerPage() {
    return (
      <div className="h-screen flex flex-col bg-primary">
        <header>...</header>
        <main className="flex-1 min-h-0">
          <MarkdownViewerContainer />
        </main>
      </div>
    );
  }
  ```
- Header with back button (navigate to workspace), title "Markdown Viewer"

**Phase 4: Frontend - Integration**

**Task 4.1: Add OpenMarkdownViewer action**
- File: `frontend/src/components/ui-new/actions/index.ts`
- Action: Add new action:
  ```typescript
  OpenMarkdownViewer: {
    id: 'open-markdown-viewer',
    label: 'Markdown Viewer',
    icon: 'md-icon' as const,
    requiresTarget: ActionTargetType.NONE,
    isVisible: (ctx) => ctx.hasWorkspace,
    getTooltip: () => 'Open Markdown Viewer',
    execute: (ctx) => {
      if (!ctx.currentWorkspaceId) return;
      ctx.navigate(`/workspaces/${ctx.currentWorkspaceId}/markdown`);
    },
  },
  ```
- Add `'md-icon'` to `SpecialIconType` union: `'ide-icon' | 'copy-icon' | 'md-icon'`
- Add `OpenMarkdownViewer` to `ContextBarActionGroups.primary` array (after OpenInIDE)
- Update `isSpecialIcon()` helper to include `'md-icon'`

**Task 4.2: Update ContextBar to render MdIcon**
- File: `frontend/src/components/ui-new/primitives/ContextBar.tsx`
- Action: In `renderActionItem()`, add handling for `'md-icon'` special icon type (after the `'ide-icon'` block around line 163):
  ```tsx
  if (iconType === 'md-icon') {
    return (
      <Tooltip key={key} content={tooltip} shortcut={action.shortcut} side="left">
        <button
          className="flex items-center justify-center transition-colors drop-shadow-..."
          aria-label={tooltip}
          onClick={() => onExecuteAction(action)}
          disabled={!enabled}
        >
          <MdIcon className="size-icon-xs opacity-50 group-hover:opacity-80 transition-opacity" />
        </button>
      </Tooltip>
    );
  }
  ```

**Task 4.3: Add route to App.tsx**
- File: `frontend/src/App.tsx`
- Action: Add route inside the new UI routes section (near line 224):
  ```tsx
  <Route path="/workspaces/:workspaceId/markdown" element={<MarkdownViewerPage />} />
  ```
- Add lazy import for MarkdownViewerPage

**Task 4.4: Install frontend dependencies**
- Action: Run `pnpm add react-markdown remark-gfm rehype-highlight` in the `frontend/` directory
- These provide GitHub-flavored markdown rendering with syntax-highlighted code blocks

**Phase 5: Testing**

(See Testing Strategy section below)

### Acceptance Criteria

**AC-1: MD Icon in ContextBar**
- **Given** a user is on the workspace screen with an active workspace
- **When** the user looks at the ContextBar (floating toolbar on the right)
- **Then** they see an "MD" icon button positioned after the IDE icon
- **And** hovering shows tooltip "Open Markdown Viewer"

**AC-2: Navigation to Markdown Viewer**
- **Given** a user clicks the "MD" icon in the ContextBar
- **When** the click event fires
- **Then** the browser navigates to `/workspaces/:workspaceId/markdown`
- **And** the Markdown Viewer page loads

**AC-3: File Tree - Markdown Only**
- **Given** the Markdown Viewer page is loaded
- **When** the file tree renders
- **Then** it shows only `.md` files and directories that contain `.md` files
- **And** other file types (`.ts`, `.rs`, `.json`, etc.) are NOT shown
- **And** directories are collapsible/expandable

**AC-4: Branch Selector**
- **Given** the Markdown Viewer page is loaded
- **When** the user clicks the branch dropdown above the file tree
- **Then** they see a list of all branches from the workspace repository
- **And** the current branch is pre-selected
- **Given** the user selects a different branch
- **When** the selection changes
- **Then** the file tree refreshes to show files from the selected branch
- **And** the content area clears or updates if a file was selected

**AC-5: File Selection and Split View**
- **Given** the file tree is visible with markdown files
- **When** the user clicks a `.md` file in the tree
- **Then** the content area splits into two panes
- **And** the left pane shows an **editable textarea** with the raw markdown content in IBM Plex Mono font
- **And** the right pane shows the live rendered HTML preview that updates as the user types
- **And** a Save button is visible in the left pane header
- **And** scrolling either pane synchronizes the other pane to the same proportional position

**AC-5c: Synchronized Scroll**
- **Given** a file is open in the split editor/preview view
- **When** the user scrolls the editor pane
- **Then** the preview pane scrolls to the same proportional position
- **When** the user scrolls the preview pane
- **Then** the editor pane scrolls to the same proportional position
- **And** no infinite scroll loop occurs (smooth, one-directional sync per user gesture)

**AC-5b: Save Edited File**
- **Given** the user has modified the markdown content in the editor
- **When** the Save button shows an unsaved changes indicator (dot/asterisk)
- **And** the user clicks Save or presses Ctrl+S / Cmd+S
- **Then** the file is saved to disk via the API
- **And** a success notification appears
- **And** the unsaved changes indicator disappears

**AC-6: Rendered Markdown Quality**
- **Given** a markdown file is selected for preview
- **When** the preview renders
- **Then** headings, lists, code blocks, tables, links, and images render correctly
- **And** GitHub-Flavored Markdown extensions (tables, task lists, strikethrough) work
- **And** code blocks have syntax highlighting

**AC-7: Git Action - Commit & Push**
- **Given** the user selects "Commit & Push" from the action dropdown
- **When** the user clicks "DO!"
- **Then** all uncommitted changes are staged, committed with an auto-generated message, and pushed to the remote
- **And** a success notification appears
- **And** if the operation fails, an error message is shown

**AC-8: Git Action - Merge to Review**
- **Given** the user selects "Merge to Review" from the action dropdown
- **When** the user clicks "DO!"
- **Then** the current branch is merged into the `review` branch
- **And** the merge result is pushed to the remote
- **And** if conflicts occur, the existing ResolveConflictsDialog opens

**AC-9: Git Action - Merge to Stable**
- **Given** the user selects "Merge to Stable" from the action dropdown
- **When** the user clicks "DO!"
- **Then** the current branch is merged into the `stable` branch
- **And** the merge result is pushed to the remote
- **And** if conflicts occur, the existing ResolveConflictsDialog opens

**AC-10: Back Navigation**
- **Given** the user is on the Markdown Viewer page
- **When** the user clicks the back button in the header
- **Then** they are navigated back to the workspace view `/workspaces/:workspaceId`

**AC-11: Empty State**
- **Given** the workspace repository contains no `.md` files
- **When** the Markdown Viewer loads
- **Then** the file tree shows an empty state message: "No markdown files found"
- **And** the content area shows a placeholder message

**AC-12b: Context Menu - Rename**
- **Given** the user right-clicks on a file or directory in the file tree
- **When** they select "Rename" from the context menu
- **Then** the item's name becomes an editable inline input, pre-filled with the current name
- **And** the input is auto-focused with the name selected (excluding .md extension for files)
- **Given** the user types a new name and presses Enter
- **When** the rename completes
- **Then** the file/directory is renamed on disk via the API
- **And** the tree refreshes to show the new name
- **And** if the renamed file was selected in the editor, the editor updates the file path
- **Given** the user presses Escape
- **Then** the rename is cancelled and the original name is restored

**AC-12c: Context Menu - Delete**
- **Given** the user right-clicks on a file or directory in the file tree
- **When** they select "Delete" from the context menu
- **Then** a confirmation dialog appears: "Delete {name}? This action cannot be undone."
- **Given** the user confirms deletion
- **When** the delete completes
- **Then** the file/directory is deleted from disk via the API
- **And** the tree refreshes
- **And** if the deleted file was selected in the editor, the editor clears to the empty state
- **Given** the user cancels
- **Then** nothing happens

**AC-12d: Context Menu - New File**
- **Given** the user right-clicks on a directory (or empty area) in the file tree
- **When** they select "New File" from the context menu
- **Then** an inline input appears inside the target directory for entering the file name
- **Given** the user types a name and presses Enter
- **When** the creation completes
- **Then** an empty `.md` file is created (`.md` extension auto-appended if not provided)
- **And** the tree refreshes and the new file is auto-selected in the editor
- **Given** the user presses Escape
- **Then** the creation is cancelled

**AC-12e: Context Menu - New Folder**
- **Given** the user right-clicks on a directory (or empty area) in the file tree
- **When** they select "New Folder" from the context menu
- **Then** an inline input appears inside the target directory for entering the folder name
- **Given** the user types a name and presses Enter
- **When** the creation completes
- **Then** a new directory is created on disk
- **And** the tree refreshes with the new directory expanded
- **Given** the user presses Escape
- **Then** the creation is cancelled

**AC-12: Keyboard Navigation**
- **Given** the file tree is focused
- **When** the user presses Up/Down arrow keys
- **Then** the selection moves between files and directories
- **When** the user presses Enter on a file
- **Then** the file content loads in the split view
- **When** the user presses Enter on a directory
- **Then** the directory toggles expand/collapse

## Additional Context

### Dependencies

**New npm packages (frontend):**
- `react-markdown` (^9.x) - Markdown to React component rendering
- `remark-gfm` (^4.x) - GitHub Flavored Markdown support
- `rehype-highlight` (^7.x) - Syntax highlighting for code blocks

**Additional npm package:**
- `@radix-ui/react-context-menu` (^2.x) - Accessible right-click context menu for the file tree

**No new Rust crates needed** - git2 and existing filesystem services cover all backend needs.

### Testing Strategy

#### Unit Tests (Frontend - Vitest)

**Test File: `frontend/src/components/markdown/__tests__/MdIcon.test.tsx`**
- Renders "MD" text
- Applies className prop
- Matches snapshot

**Test File: `frontend/src/components/markdown/__tests__/MarkdownFileTreeView.test.tsx`**
- Renders file tree with correct structure
- Shows only .md files and directories
- Highlights selected file
- Calls onSelectFile when file clicked
- Calls onToggleDir when directory clicked
- Handles empty tree (empty state message)
- Keyboard navigation: ArrowDown moves selection down
- Keyboard navigation: ArrowUp moves selection up
- Keyboard navigation: Enter on file calls onSelectFile
- Keyboard navigation: Enter on directory calls onToggleDir
- Right-click on file shows context menu with Rename, Delete
- Right-click on directory shows context menu with New File, New Folder, Rename, Delete
- Right-click on empty area shows context menu with New File, New Folder
- Inline rename input appears when renamingPath is set
- Inline rename submits on Enter, cancels on Escape
- Inline create input appears when creatingAt is set
- Inline create submits on Enter, cancels on Escape
- Inline create auto-appends .md for file type

**Test File: `frontend/src/components/markdown/__tests__/BranchSelectorView.test.tsx`**
- Renders dropdown with branch names
- Shows current branch as selected
- Calls onSelectBranch when selection changes
- Shows loading state
- Handles empty branch list

**Test File: `frontend/src/components/markdown/__tests__/GitActionBarView.test.tsx`**
- Renders dropdown with 3 action options
- Shows selected action
- Calls onSelectAction when dropdown changes
- Calls onExecute when DO! button clicked
- Disables DO! button when isExecuting is true
- Shows spinner when isExecuting

**Test File: `frontend/src/components/markdown/__tests__/MarkdownRawView.test.tsx`**
- Renders content in pre/code block
- Uses monospace font
- Shows file path
- Handles empty content

**Test File: `frontend/src/components/markdown/__tests__/MarkdownPreviewView.test.tsx`**
- Renders headings correctly (h1-h6)
- Renders code blocks with syntax highlighting
- Renders tables (GFM)
- Renders task lists (GFM)
- Renders links
- Renders images
- Handles empty content

**Test File: `frontend/src/hooks/__tests__/useMarkdownViewer.test.ts`**
- useMarkdownTree fetches and returns file tree
- useMarkdownTree handles error state
- useFileContent fetches content for given path
- useFileContent caches results
- useBranches returns branch list
- useCheckoutBranch mutation succeeds
- useCheckoutBranch mutation handles errors
- useCommitAndPush mutation succeeds
- useMergeToBranch mutation succeeds
- useCreateFile mutation succeeds and invalidates tree
- useCreateDirectory mutation succeeds and invalidates tree
- useRenameEntry mutation succeeds and updates selected path
- useDeleteEntry mutation succeeds and clears selection if needed

#### Unit Tests (Backend - cargo test)

**Test File: `crates/services/src/services/filesystem_test.rs` or inline**
- `list_markdown_files` returns only .md files
- `list_markdown_files` includes parent directories of .md files
- `list_markdown_files` excludes empty directories
- `list_markdown_files` handles nested directories
- `read_file_content` reads .md file successfully
- `read_file_content` rejects non-.md files
- `read_file_content` rejects path traversal attacks (../)
- `read_file_content` returns error for non-existent file
- `create_file` creates an empty .md file
- `create_file` rejects non-.md names
- `create_file` rejects path traversal
- `create_directory` creates a new directory
- `rename_entry` renames a file and returns new path
- `rename_entry` renames a directory
- `rename_entry` rejects renaming file to non-.md extension
- `rename_entry` rejects path traversal in new name
- `delete_entry` deletes a file
- `delete_entry` deletes an empty directory
- `delete_entry` rejects non-empty directory

#### Integration Tests (Backend)

**Test File: `crates/server/tests/filesystem_routes.rs` or similar**
- GET `/api/filesystem/markdown-tree` returns filtered tree
- GET `/api/filesystem/file-content` returns file content
- GET `/api/filesystem/file-content` with invalid path returns 400
- POST `/api/task-attempts/:id/checkout-branch` switches branch
- POST `/api/task-attempts/:id/commit-and-push` creates commit and pushes
- POST `/api/task-attempts/:id/merge-to-branch` merges to target branch

#### E2E Tests (Playwright)

**Test File: `frontend/e2e/markdown-viewer.spec.ts` (NEW)**

```
Test: "MD icon is visible in ContextBar"
  - Navigate to workspace page
  - Verify MD icon is visible in context bar
  - Verify tooltip shows "Open Markdown Viewer"

Test: "Opens Markdown Viewer on MD icon click"
  - Navigate to workspace page
  - Click MD icon
  - Verify URL changes to /workspaces/:id/markdown
  - Verify page loads with file tree and content area

Test: "File tree shows only markdown files"
  - Open Markdown Viewer
  - Verify .md files are shown
  - Verify non-markdown files are NOT shown

Test: "Selecting a file shows split view"
  - Open Markdown Viewer
  - Click a .md file in the tree
  - Verify left pane shows raw markdown
  - Verify right pane shows rendered HTML
  - Verify rendered HTML contains proper heading elements

Test: "Branch selector switches branches"
  - Open Markdown Viewer
  - Open branch dropdown
  - Select a different branch
  - Verify file tree updates

Test: "Git action Commit & Push works"
  - Open Markdown Viewer
  - Select "Commit & Push" from dropdown
  - Click DO! button
  - Verify success notification appears

Test: "Back navigation returns to workspace"
  - Open Markdown Viewer
  - Click back button
  - Verify URL returns to /workspaces/:id

Test: "Keyboard navigation in file tree"
  - Open Markdown Viewer
  - Focus file tree
  - Press ArrowDown
  - Verify next item is highlighted
  - Press Enter
  - Verify file content loads

Test: "Right-click context menu on file"
  - Open Markdown Viewer
  - Right-click a .md file
  - Verify context menu shows Rename and Delete

Test: "Rename file via context menu"
  - Right-click a file, select Rename
  - Verify inline input appears with current name
  - Type new name, press Enter
  - Verify tree updates with new name

Test: "Delete file via context menu"
  - Right-click a file, select Delete
  - Verify confirmation dialog appears
  - Click confirm
  - Verify file removed from tree

Test: "Create new file via context menu"
  - Right-click a directory, select New File
  - Verify inline input appears
  - Type name, press Enter
  - Verify new file appears in tree and opens in editor
```

### Notes

1. **Security**: The `read_file_content` endpoint MUST validate that the requested path is within the workspace's worktree directory. Use `canonicalize()` to prevent path traversal attacks.

2. **Performance**: The file tree should be loaded lazily - only expand directories when the user clicks them. The initial load should show only top-level entries.

3. **Branch names**: The "Review" and "Stable" branch names should ideally be configurable per-project. For the initial implementation, use `review` and `stable` as defaults. If these branches don't exist, the merge action should show an error message.

4. **Commit message**: For "Commit & Push", auto-generate a message like: `docs: update documentation [auto-commit from MD viewer]`.

5. **File watching**: Not included in v1. The user must manually refresh (F5 or a refresh button) to see file changes made outside the viewer.

6. **Responsive layout**: The split pane should collapse to a single pane on narrow screens, with tabs to switch between raw and preview.

## UX Design Specification

### Layout Structure

```
+----------------------------------------------------------------------+
| [<- Back]           Markdown Viewer - {workspace_name}               |
+----------------------------------------------------------------------+
| SIDEBAR (250px)    |  CONTENT AREA                                   |
|                    |                                                  |
| [Branch: main  v]  |  +---------------------+----------------------+ |
|                    |  | RAW MARKDOWN         | HTML PREVIEW         | |
| -- docs/           |  |                      |                      | |
|    |-- README.md   |  | # Heading            | Heading              | |
|    |-- GUIDE.md *  |  |                      |                      | |
|    |-- arch/       |  | Some **bold** text   | Some bold text       | |
|       |-- adr.md   |  |                      |                      | |
| -- CHANGELOG.md    |  | ```rust              | [syntax highlighted] | |
| -- README.md       |  | fn main() {}         |                      | |
|                    |  | ```                  |                      | |
|                    |  |                      |                      | |
|                    |  |                      |                      | |
|                    |  |                      |                      | |
|                    |  +---------------------+----------------------+ |
| [Commit & Push  v] |                                                  |
| [  DO!  ]          |                                                  |
+----------------------------------------------------------------------+
```

### Component Dimensions

- **Sidebar width**: 250px fixed, with horizontal resize handle (stretch goal)
- **Branch selector**: Full width of sidebar, 32px height
- **File tree**: Fills remaining sidebar space, scrollable
- **Git action bar**: Fixed at bottom of sidebar, 64px height
- **Content split**: 50/50 split, both panes independently scrollable
- **Header**: 48px height with back button and title

### Color Scheme

- Follow existing Tailwind theme variables (bg-primary, bg-secondary, text-normal, text-low)
- Selected file: `bg-accent/10` background
- File icons: `text-low`, directory icons: `text-low`
- Raw markdown pane: `bg-secondary` background, monospace font
- HTML preview: `bg-primary` background, prose styling

### Interactive States

- File hover: `bg-secondary/50`
- File selected: `bg-accent/10` with left border accent
- Branch dropdown: Standard select styling
- DO! button: `bg-accent text-white`, hover `bg-accent/90`, disabled `opacity-50`
- Loading states: Skeleton placeholders for file tree and content

### Accessibility

- All interactive elements have aria-labels
- File tree uses `role="tree"` and `role="treeitem"` ARIA roles
- Keyboard navigable (Tab, Arrow keys, Enter, Escape)
- Focus visible indicators on all interactive elements
- Branch selector labeled with `aria-label="Select branch"`
- Color contrast meets WCAG AA standards (inherited from theme)
