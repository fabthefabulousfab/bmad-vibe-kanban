---
title: 'UX Design - Markdown Documentation Viewer'
created: '2026-03-12'
status: 'ready-for-dev'
related_spec: '../tech-spec-markdown-viewer.md'
---

# UX Design: Markdown Documentation Viewer

## 1. Screen Map

```
Workspace Screen
    |
    +-- ContextBar (floating right)
    |       |
    |       +-- [IDE Icon] (existing)
    |       +-- [MD Icon]  (NEW) --> navigates to:
    |
    +-- Markdown Viewer Page (/workspaces/:id/markdown)
            |
            +-- Header Bar
            |       +-- Back Button (<-)
            |       +-- Title: "Markdown Viewer - {workspace}"
            |
            +-- Main Content (flex row)
                    |
                    +-- Left Sidebar (250px fixed)
                    |       +-- Branch Selector Dropdown
                    |       +-- File Tree (scrollable)
                    |       |       +-- Right-click Context Menu
                    |       |               +-- On file: Rename, Delete
                    |       |               +-- On dir: New File, New Folder, Rename, Delete
                    |       |               +-- On empty: New File, New Folder
                    |       |       +-- Inline Rename Input
                    |       |       +-- Inline Create Input
                    |       +-- Git Action Bar (fixed bottom)
                    |               +-- Action Dropdown
                    |               +-- DO! Button
                    |
                    +-- Content Area (flex: 1)
                            +-- Split Pane (50/50, synchronized scroll)
                                    +-- Left: Editable Markdown Editor
                                    |       +-- Save Button (top-right)
                                    +-- Right: HTML Preview (live)
                                    +-- [Scroll sync: proportional bidirectional]
```

## 2. Wireframes

### 2.1 Full Page Layout

```
+===========================================================================+
||  [<-]  Markdown Viewer - my-workspace                                   ||
+===========================================================================+
|                    |                                                       |
| [Branch: main  v] |  +-------------------------------------------------+ |
| __________________ |  |                                                   | |
|                    |  |        (No file selected)                          | |
| > docs/            |  |                                                   | |
|   > architecture/  |  |   Select a markdown file from the tree            | |
|     architecture.md|  |   to view its contents.                           | |
|   > prd/           |  |                                                   | |
|     prd.md         |  |                                                   | |
| > _bmad/           |  |                                                   | |
|   README.md        |  |                                                   | |
| CHANGELOG.md       |  |                                                   | |
| README.md          |  |                                                   | |
| DOCUMENTATION.md   |  |                                                   | |
|                    |  |                                                   | |
|                    |  +-------------------------------------------------+ |
| __________________ |                                                       |
| [Commit & Push v]  |                                                       |
| [     DO!      ]   |                                                       |
+===========================================================================+
```

### 2.2 File Selected - Split View (Editor + Preview)

```
+===========================================================================+
||  [<-]  Markdown Viewer - my-workspace                                   ||
+===========================================================================+
|                    |                                                       |
| [Branch: main  v]  | +------------------------+------------------------+ |
| __________________ | | README.md* (edit) [Save]| README.md (preview)    | |
|                    | |                        |                        | |
|   docs/            | | # My Project_          | My Project             | |
|   > architecture/  | |                        | =========              | |
|     architecture.md| | A description of       |                        | |
|   > prd/           | | the project.           | A description of       | |
|     prd.md         | |                        | the project.           | |
|   _bmad/           | | ## Getting Started      |                        | |
|     README.md      | |                        | Getting Started        | |
|   CHANGELOG.md     | | ```bash                | -------------          | |
| * README.md        | | npm install            |                        | |
|   DOCUMENTATION.md | | ```                    | +--------------------+ | |
|                    | |                        | | npm install         | | |
|                    | | ## Features            | +--------------------+ | |
|                    | |                        |                        | |
|                    | | - Feature A            | Features               | |
|                    | | - Feature B            | --------               | |
|                    | | - Feature C            | * Feature A            | |
|                    | |                        | * Feature B            | |
| __________________ | |                        | * Feature C            | |
| [Commit & Push v]  | +------------------------+------------------------+ |
| [     DO!      ]   |                                                       |
+===========================================================================+

Legend:
  * (in title) = unsaved changes indicator
  _ = cursor position (editable textarea)
  * (in tree) = selected file (highlighted row)
  > = collapsed directory
  (no >) = expanded directory
  [Save] = Save button (brand orange when dirty, dimmed when clean)
```

### 2.3 Branch Selector Expanded

```
+====================+
| [Branch: main  v]  |
| +----------------+ |
| | main         * | |
| | develop        | |
| | feature/docs   | |
| | review         | |
| | stable         | |
| +----------------+ |
+====================+
```

### 2.4 Git Action Dropdown Expanded

```
+====================+
| [Commit & Push  v] |
| +----------------+ |
| | Commit & Push *| |
| | Merge Review   | |
| | Merge Stable   | |
| +----------------+ |
| [     DO!      ]   |
+====================+
```

### 2.5 Empty State

```
+===========================================================================+
||  [<-]  Markdown Viewer - my-workspace                                   ||
+===========================================================================+
|                    |                                                       |
| [Branch: main  v]  |                                                       |
| __________________ |                                                       |
|                    |          No markdown files found                      |
|  (empty tree)      |                                                       |
|                    |   This repository does not contain any .md files.     |
|  No .md files      |                                                       |
|  found in this     |                                                       |
|  branch.           |                                                       |
|                    |                                                       |
| __________________ |                                                       |
| [Commit & Push v]  |                                                       |
| [     DO!      ]   |                                                       |
+===========================================================================+
```

### 2.6 Loading State

```
+===========================================================================+
||  [<-]  Markdown Viewer - my-workspace                                   ||
+===========================================================================+
|                    |                                                       |
| [Branch: -----v]  |  +-------------------------------------------------+ |
| __________________ |  |                                                   | |
|                    |  |                                                   | |
| [====       ]      |  |          [====       ]                            | |
| [======     ]      |  |          [========         ]                      | |
| [===        ]      |  |          [====       ]                            | |
| [=======    ]      |  |                                                   | |
|                    |  |                                                   | |
|                    |  +-------------------------------------------------+ |
| __________________ |                                                       |
| [Commit & Push v]  |                                                       |
| [     DO!      ]   |                                                       |
+===========================================================================+

Legend: [===] = skeleton loading placeholder
```

### 2.7 Error State (Git Action)

```
+-----------------------------------------+
|  Error                                  |
|                                         |
|  Failed to merge to review branch.      |
|  Branch 'review' does not exist.        |
|                                         |
|                          [OK]           |
+-----------------------------------------+
```

### 2.8 Confirm Dialog (Merge Action)

```
+-----------------------------------------+
|  Merge to Review                        |
|                                         |
|  This will merge branch 'feature/docs'  |
|  into 'review' and push to remote.      |
|                                         |
|  Are you sure?                          |
|                                         |
|              [Cancel]    [Merge]        |
+-----------------------------------------+
```

### 2.9 Context Menu - Right-click on File

```
|                    |
|   docs/            |
|   > architecture/  |
|     architecture.md|
|   > prd/           |
|     prd.md         |
|   _bmad/           |
|     README.md      |
|   CHANGELOG.md     |
| * README.md   +-----------+
|   DOCUMENTATI | Rename     |
|               | Delete     |
|               +-----------+
| __________________ |
```

### 2.10 Context Menu - Right-click on Directory

```
|                    |
|   docs/            |
|   > architecture/  |
|     architecture.md|
|   > prd/  +----------------+
|     prd.md| New File       |
|   _bmad/  | New Folder     |
|     READM |----------------|
|   CHANGEL | Rename         |
|           | Delete         |
|           +----------------+
| __________________ |
```

### 2.11 Context Menu - Right-click on Empty Area

```
|                    |
|   docs/            |
|   CHANGELOG.md     |
|   README.md        |
|                    |
|            +----------------+
|            | New File       |
|            | New Folder     |
|            +----------------+
|                    |
| __________________ |
```

### 2.12 Inline Rename (file being renamed)

```
|                    |
|   docs/            |
|   > architecture/  |
|   > prd/           |
|     prd.md         |
|   _bmad/           |
|   CHANGELOG.md     |
| * [READM|E.md    ] |   <-- inline <input>, name selected
|   DOCUMENTATION.md |
|                    |
```

### 2.13 Inline Create (new file in directory)

```
|                    |
|   docs/            |
|   > architecture/  |
|   > prd/           |
|     prd.md         |
|     [new-file|.md] |   <-- inline <input> for new file
|   _bmad/           |
|   CHANGELOG.md     |
|   README.md        |
|                    |
```

### 2.14 Delete Confirmation Dialog

```
+-----------------------------------------+
|  Delete File                            |
|                                         |
|  Are you sure you want to delete        |
|  "architecture.md"?                     |
|                                         |
|  This action cannot be undone.          |
|                                         |
|              [Cancel]    [Delete]       |
+-----------------------------------------+
```

## 3. Component Hierarchy

```
MarkdownViewerPage
  |-- Header
  |     |-- BackButton (Phosphor: ArrowLeft)
  |     |-- Title text
  |
  |-- MarkdownViewerContainer
        |-- LeftSidebar
        |     |-- BranchSelectorView
        |     |     |-- <select> element
        |     |
        |     |-- MarkdownFileTreeView
        |     |     |-- Radix ContextMenu.Root (wraps each node)
        |     |     |     |-- ContextMenu.Trigger -> FileTreeNode
        |     |     |     |-- ContextMenu.Content (portal)
        |     |     |           |-- ContextMenu.Item "New File" (dirs only)
        |     |     |           |-- ContextMenu.Item "New Folder" (dirs only)
        |     |     |           |-- ContextMenu.Separator (dirs only)
        |     |     |           |-- ContextMenu.Item "Rename"
        |     |     |           |-- ContextMenu.Item "Delete"
        |     |     |
        |     |     |-- FileTreeNode (recursive)
        |     |     |     |-- (if renamingPath matches) InlineRenameInput
        |     |     |     |-- (else) FolderSimple / FileText icon + label
        |     |     |     |-- FileTreeNode (children)
        |     |     |     |-- (if creatingAt matches) InlineCreateInput
        |     |     |
        |     |     |-- Radix ContextMenu.Root (wraps empty area)
        |     |           |-- ContextMenu.Item "New File" (at root)
        |     |           |-- ContextMenu.Item "New Folder" (at root)
        |     |
        |     |-- GitActionBarView
        |           |-- <select> element
        |           |-- Button "DO!"
        |
        |-- ContentArea
              |-- (if no file selected) EmptyPlaceholder
              |-- (if file selected) SplitPane
                    |-- [useSyncScroll hook: bidirectional proportional scroll sync]
                    |
                    |-- MarkdownEditorView (ref=editorRef, onScroll=onEditorScroll)
                    |     |-- Header row
                    |     |     |-- File path label
                    |     |     |-- Unsaved indicator (* dot)
                    |     |     |-- Save button (Ctrl+S / Cmd+S)
                    |     |-- <textarea> (editable, monospace, scroll synced)
                    |
                    |-- MarkdownPreviewView (ref=previewRef, onScroll=onPreviewScroll)
                          |-- ReactMarkdown (live updates, scroll synced)
                                |-- remark-gfm plugin
                                |-- rehype-highlight plugin
```

## 4. Interaction Flows

### 4.1 Open Markdown Viewer

```
User                    ContextBar              Router              Page
 |                         |                       |                  |
 |-- hover MD icon ------->|                       |                  |
 |<-- tooltip "Markdown"---|                       |                  |
 |                         |                       |                  |
 |-- click MD icon ------->|                       |                  |
 |                         |-- navigate ---------->|                  |
 |                         |   /workspaces/:id/md  |                  |
 |                         |                       |-- mount -------->|
 |                         |                       |                  |-- fetch repos
 |                         |                       |                  |-- fetch branches
 |                         |                       |                  |-- fetch file tree
 |<-------------------------------------------------------- render ---|
```

### 4.2 Select File

```
User              FileTree            Container           API
 |                   |                    |                 |
 |-- click file ---->|                    |                 |
 |                   |-- onSelectFile --->|                 |
 |                   |                    |-- GET content ->|
 |                   |                    |<-- content -----|
 |                   |                    |                 |
 |<-------------- re-render (editor + preview split view) |
```

### 4.2b Edit and Save File

```
User              EditorView          Container           API
 |                   |                    |                 |
 |-- type text ----->|                    |                 |
 |                   |-- onContentChange->|                 |
 |                   |                    |-- update state  |
 |                   |                    |   (dirty=true)  |
 |<-- preview updates live --------------|                 |
 |<-- Save button turns orange ---------|                 |
 |<-- filename shows * indicator -------|                 |
 |                   |                    |                 |
 |-- click Save ---->|                    |                 |
 |   (or Ctrl+S)     |-- onSave -------->|                 |
 |                   |                    |-- PUT content ->|
 |                   |                    |<-- ok ----------|
 |                   |                    |-- dirty=false   |
 |<-- Save btn dimmed, * removed -------|                 |
```

### 4.2c Unsaved Changes Warning (on file switch)

```
User              FileTree            Container           Dialog
 |                   |                    |                 |
 |-- click other --->|                    |                 |
 |   file            |-- onSelectFile --->|                 |
 |                   |                    |-- (dirty?) ---->|
 |                   |                    |                 |-- show
 |<----------------------------------------------------- confirm?
 |   "Discard unsaved changes?"                            |
 |-- click Discard ------------------------------------------->|
 |                   |                    |<-- confirmed    |
 |                   |                    |-- load new file |
```

### 4.2d Synchronized Scroll

```
User              EditorView          useSyncScroll        PreviewView
 |                   |                    |                    |
 |-- scroll editor ->|                    |                    |
 |                   |-- onScroll ------->|                    |
 |                   |                    |-- scrollSource =   |
 |                   |                    |   'editor'         |
 |                   |                    |-- compute ratio:   |
 |                   |                    |   scrollTop /      |
 |                   |                    |   maxScroll         |
 |                   |                    |                    |
 |                   |                    |-- set scrollTop --->|
 |                   |                    |   (ratio * maxScroll)
 |                   |                    |                    |
 |                   |                    |-- rAF: reset ----->|
 |                   |                    |   scrollSource=null |
 |                   |                    |                    |

(Same flow in reverse when user scrolls the preview pane)

Note: scrollSource ref prevents infinite loops.
When scrollSource='editor', preview's onScroll is ignored (and vice versa).
Reset to null after requestAnimationFrame completes.
```

### 4.2e Rename File/Directory (Context Menu)

```
User              FileTree            Container           API
 |                   |                    |                 |
 |-- right-click --->|                    |                 |
 |<-- context menu --|                    |                 |
 |-- click Rename -->|                    |                 |
 |                   |-- onContextMenu    |                 |
 |                   |   ('rename', path) |                 |
 |                   |                    |-- set state:    |
 |                   |                    |   renamingPath  |
 |<-- inline input --|                    |                 |
 |                   |                    |                 |
 |-- type new name ->|                    |                 |
 |-- press Enter --->|                    |                 |
 |                   |-- onRenameSubmit ->|                 |
 |                   |                    |-- POST rename ->|
 |                   |                    |<-- new path ----|
 |                   |                    |-- invalidate    |
 |                   |                    |   tree query    |
 |<-- tree refreshed, new name shown ----|                 |
```

### 4.2f Delete File/Directory (Context Menu)

```
User              FileTree            Container           Dialog       API
 |                   |                    |                 |            |
 |-- right-click --->|                    |                 |            |
 |<-- context menu --|                    |                 |            |
 |-- click Delete -->|                    |                 |            |
 |                   |-- onContextMenu    |                 |            |
 |                   |   ('delete', path) |                 |            |
 |                   |                    |-- show -------->|            |
 |<----------------------------------------------- confirm?|            |
 |   "Delete {name}? This cannot be undone."               |            |
 |-- click Delete ---------------------------------------->|            |
 |                   |                    |<-- confirmed    |            |
 |                   |                    |-- DELETE ------>|----------->|
 |                   |                    |<-- ok ----------|            |
 |                   |                    |-- invalidate    |            |
 |                   |                    |   tree query    |            |
 |                   |                    |-- clear sel if  |            |
 |                   |                    |   deleted=sel   |            |
 |<-- tree refreshed, item removed ------|                 |            |
```

### 4.2g Create New File/Folder (Context Menu)

```
User              FileTree            Container           API
 |                   |                    |                 |
 |-- right-click --->|                    |                 |
 |   on directory    |                    |                 |
 |<-- context menu --|                    |                 |
 |-- click "New File"|                    |                 |
 |                   |-- onContextMenu    |                 |
 |                   |   ('new-file',dir) |                 |
 |                   |                    |-- set state:    |
 |                   |                    |   creatingAt =  |
 |                   |                    |   { dir, 'file'}|
 |                   |                    |-- expand dir    |
 |<-- inline input --|                    |                 |
 |   inside target   |                    |                 |
 |   directory       |                    |                 |
 |                   |                    |                 |
 |-- type name ----->|                    |                 |
 |-- press Enter --->|                    |                 |
 |                   |-- onCreateSubmit ->|                 |
 |                   |                    |-- POST create ->|
 |                   |                    |<-- ok ----------|
 |                   |                    |-- invalidate    |
 |                   |                    |   tree query    |
 |                   |                    |-- auto-select   |
 |                   |                    |   new file      |
 |<-- tree refreshed, new file selected -|                 |

Note: for "New Folder", same flow except no auto-select in editor.
.md extension auto-appended for files if not provided by user.
```

### 4.3 Switch Branch

```
User            BranchSelector      Container           API
 |                   |                  |                  |
 |-- select branch ->|                  |                  |
 |                   |-- onSelect ----->|                  |
 |                   |                  |-- POST checkout->|
 |                   |                  |<-- ok ---------- |
 |                   |                  |-- GET tree ----->|
 |                   |                  |<-- new tree -----|
 |                   |                  |                  |
 |<------------ re-render (new tree, clear content)       |
```

### 4.4 Execute Git Action

```
User          ActionBar         Container           API           Dialog
 |               |                 |                  |              |
 |-- select ---->|                 |                  |              |
 |   action      |                 |                  |              |
 |-- click DO! ->|                 |                  |              |
 |               |-- onExecute --->|                  |              |
 |               |                 |-- show confirm ->|              |
 |               |                 |                  |              |-- show
 |<-------------------------------------------------------------- confirm?
 |-- click Yes -------------------------------------------------------->|
 |               |                 |<-- confirmed ----|              |
 |               |                 |-- POST action -->|              |
 |               |                 |<-- result -------|              |
 |               |                 |                  |              |
 |<------------ success toast / error dialog          |              |
```

## 5. Responsive Behavior

### Desktop (>1024px)
- Full layout as designed: sidebar (250px) + split content (50/50)

### Tablet (768px - 1024px)
- Sidebar collapses to 200px
- Content split remains 50/50

### Mobile (<768px)
- Sidebar becomes a slide-out drawer (toggle via hamburger icon)
- Content area uses tabs: "Edit" | "Preview" (no split)
- Git action bar moves to bottom sheet

## 6. Tailwind CSS Specifications

### Sidebar
```
className="w-[250px] flex flex-col border-r bg-secondary/30"
```

### Branch Selector
```
className="w-full h-8 px-2 bg-secondary border rounded text-sm text-normal"
```

### File Tree Item
```
// Default
className="flex items-center gap-1.5 px-2 py-1 text-sm cursor-pointer hover:bg-secondary/50 transition-colors"

// Selected
className="flex items-center gap-1.5 px-2 py-1 text-sm cursor-pointer bg-accent/10 border-l-2 border-accent"

// Directory
className="flex items-center gap-1.5 px-2 py-1 text-sm cursor-pointer hover:bg-secondary/50 font-medium"
```

### Content Panes
```
// Container
className="flex-1 grid grid-cols-2 min-h-0"

// Editor Pane Container
className="flex flex-col border-r"

// Editor Header (file path + save button)
className="flex items-center justify-between px-base py-half border-b bg-secondary/30"

// Editor Textarea (scroll synced with preview via useSyncScroll)
className="flex-1 w-full resize-none p-4 bg-secondary/20 font-mono text-sm text-normal focus:outline-none"
// ref={editorRef} onScroll={onEditorScroll}

// Save Button (clean state)
className="px-base py-half text-xs rounded bg-secondary/50 text-low cursor-default opacity-50"

// Save Button (dirty / has changes)
className="px-base py-half text-xs rounded bg-brand text-white font-semibold hover:bg-brand-hover transition-colors"

// Save Button (saving)
className="px-base py-half text-xs rounded bg-brand/70 text-white cursor-wait"

// Unsaved indicator dot
className="w-1.5 h-1.5 rounded-full bg-brand animate-pulse"

// Preview Pane (scroll synced with editor via useSyncScroll)
className="overflow-auto p-4 prose prose-sm dark:prose-invert max-w-none"
// ref={previewRef} onScroll={onPreviewScroll}
```

### Context Menu (Radix ContextMenu)
```
// Menu content container
className="min-w-[160px] bg-secondary border border-border rounded-md py-1 shadow-lg z-50"

// Menu item
className="flex items-center gap-2 px-3 py-1.5 text-sm text-normal cursor-pointer outline-none
           data-[highlighted]:bg-secondary/80 data-[highlighted]:text-high transition-colors"

// Menu item (destructive / delete)
className="flex items-center gap-2 px-3 py-1.5 text-sm text-error cursor-pointer outline-none
           data-[highlighted]:bg-error/10 data-[highlighted]:text-error transition-colors"

// Menu separator
className="h-px my-1 bg-border"

// Menu item icon
className="size-icon-sm text-low"
```

### Inline Rename / Create Input
```
// Inline input (replaces file name in tree item)
className="h-6 px-1 text-sm bg-primary border border-brand rounded-sm outline-none
           text-high font-normal caret-brand"
// auto-focus, select text on mount (for rename: select name without .md)

// Inline input container (same padding as tree-item)
className="flex items-center gap-1.5 px-2 py-0.5"
```

### Git Action Bar
```
className="border-t p-2 space-y-2"

// DO! Button
className="w-full h-8 bg-accent text-white font-semibold rounded hover:bg-accent/90 disabled:opacity-50 transition-colors"
```

### Header
```
className="h-12 flex items-center gap-3 px-4 border-b bg-secondary/30"
```

## 7. Icon Specifications

| Element | Icon | Source | Size Class |
|---------|------|--------|------------|
| MD Button (ContextBar) | "MD" text badge | Custom component | size-icon-xs |
| Back Button | ArrowLeft | @phosphor-icons/react | size-icon-base |
| Directory (collapsed) | CaretRight | @phosphor-icons/react | size-icon-xs |
| Directory (expanded) | CaretDown | @phosphor-icons/react | size-icon-xs |
| Directory folder | FolderSimple | @phosphor-icons/react | size-icon-sm |
| Markdown file | FileText | @phosphor-icons/react | size-icon-sm |
| Loading spinner | SpinnerGap | @phosphor-icons/react | size-icon-base |
| Save button icon | FloppyDisk | @phosphor-icons/react | size-icon-sm |
| Saving spinner | SpinnerGap | @phosphor-icons/react | size-icon-xs |
| Context menu: Rename | PencilSimple | @phosphor-icons/react | size-icon-sm |
| Context menu: Delete | Trash | @phosphor-icons/react | size-icon-sm |
| Context menu: New File | FilePlus | @phosphor-icons/react | size-icon-sm |
| Context menu: New Folder | FolderPlus | @phosphor-icons/react | size-icon-sm |

## 8. Animation and Transitions

| Element | Transition | Duration |
|---------|-----------|----------|
| File hover | background-color | 150ms |
| File selection | background-color, border | 150ms |
| Directory expand/collapse | height (auto) | 200ms ease-out |
| DO! button hover | background-color | 150ms |
| Loading skeletons | opacity pulse | 1.5s infinite |
| Page mount | opacity 0->1 | 200ms |
| Save button state change | background-color, opacity | 150ms |
| Unsaved indicator dot | opacity pulse | 1.5s infinite |
| Save spinner | rotate 360deg | 1s linear infinite |
| Context menu open | scale(0.95)->1, opacity 0->1 | 100ms ease-out |
| Context menu item highlight | background-color | 100ms |
| Inline input focus | border-color (brand) | 150ms |

## 9. Accessibility Checklist

- [ ] File tree uses `role="tree"` / `role="treeitem"` / `aria-expanded`
- [ ] Branch selector has `aria-label="Select git branch"`
- [ ] Action dropdown has `aria-label="Select git action"`
- [ ] DO! button has `aria-label="Execute selected git action"`
- [ ] Back button has `aria-label="Back to workspace"`
- [ ] Selected file announced via `aria-selected="true"`
- [ ] All color contrasts meet WCAG AA (4.5:1 for text)
- [ ] Focus indicators visible on all interactive elements
- [ ] Tab order: Header -> Branch selector -> File tree -> Content -> Action bar
- [ ] Screen reader: file tree items announce file name and type (file/folder)
- [ ] Editor textarea has `aria-label="Edit markdown content for {filename}"`
- [ ] Save button has `aria-label="Save file"` and `aria-disabled` when no changes
- [ ] Unsaved changes announced via `aria-live="polite"` region
- [ ] Ctrl+S / Cmd+S keyboard shortcut for save (prevents default browser save)
- [ ] Tab order includes: Editor textarea -> Save button (between file tree and action bar)
- [ ] Synchronized scroll does not interfere with assistive technology scroll behavior
- [ ] Scroll sync uses `requestAnimationFrame` for smooth, non-janky performance
- [ ] Context menu uses Radix `ContextMenu` with built-in keyboard navigation (Arrow keys, Enter, Escape)
- [ ] Context menu items have `role="menuitem"` (handled by Radix)
- [ ] Delete menu item has `aria-label` indicating destructive action
- [ ] Inline rename input has `aria-label="Rename {filename}"`
- [ ] Inline create input has `aria-label="Enter name for new {file|folder}"`
- [ ] Inline inputs auto-focus on mount and trap focus until confirmed or cancelled
- [ ] Delete confirmation dialog is focusable and traps focus (existing ConfirmDialog pattern)
