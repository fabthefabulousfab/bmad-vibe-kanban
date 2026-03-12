---
title: 'Test Plan - Markdown Documentation Viewer'
created: '2026-03-12'
status: 'ready-for-dev'
related_spec: 'tech-spec-markdown-viewer.md'
coverage_target: '80% minimum'
---

# Test Plan: Markdown Documentation Viewer

## 1. Test Matrix Overview

| Layer | Framework | Location | Count |
|-------|-----------|----------|-------|
| Backend Unit | cargo test | `crates/services/src/services/` | 23 tests |
| Backend Integration | cargo test | `crates/server/tests/` | 14 tests |
| Frontend Unit (Views) | Vitest | `frontend/src/components/markdown/__tests__/` | 63 tests |
| Frontend Unit (Hooks) | Vitest | `frontend/src/hooks/__tests__/` | 27 tests |
| Frontend Unit (Actions) | Vitest | `frontend/src/components/ui-new/actions/__tests__/` | 4 tests |
| E2E | Playwright | `frontend/e2e/` | 19 tests |
| **Total** | | | **150 tests** |

## 2. Backend Unit Tests

### 2.1 Filesystem Service - `list_markdown_files`

**File:** `crates/services/src/services/filesystem.rs` (inline tests)

```rust
#[cfg(test)]
mod tests {
    // Test data setup: create temp directory with mixed file structure

    #[tokio::test]
    async fn test_list_markdown_files_returns_only_md_files() {
        // Given: a directory with .md, .ts, .rs, .json files
        // When: list_markdown_files is called
        // Then: only .md files are included in the result
    }

    #[tokio::test]
    async fn test_list_markdown_files_includes_parent_directories() {
        // Given: a nested directory docs/arch/decisions.md
        // When: list_markdown_files is called
        // Then: docs/ and docs/arch/ directories are included as parents
    }

    #[tokio::test]
    async fn test_list_markdown_files_excludes_empty_directories() {
        // Given: a directory "empty_dir/" with no .md files (only .ts files)
        // When: list_markdown_files is called
        // Then: "empty_dir/" is NOT included in the result
    }

    #[tokio::test]
    async fn test_list_markdown_files_handles_deeply_nested() {
        // Given: files at a/b/c/d/deep.md
        // When: list_markdown_files is called
        // Then: all parent directories and the file are returned in proper tree structure
    }
}
```

### 2.2 Filesystem Service - `read_file_content`

```rust
    #[tokio::test]
    async fn test_read_file_content_reads_md_file() {
        // Given: a valid .md file with known content "# Hello World"
        // When: read_file_content is called with its path
        // Then: returns Ok("# Hello World")
    }

    #[tokio::test]
    async fn test_read_file_content_rejects_non_md_files() {
        // Given: a .ts file exists
        // When: read_file_content is called with its path
        // Then: returns Err(NotMarkdownFile)
    }

    #[tokio::test]
    async fn test_read_file_content_rejects_path_traversal() {
        // Given: a path containing "../" segments
        // When: read_file_content is called with "../../etc/passwd"
        // Then: returns Err(PathTraversal)
    }

    #[tokio::test]
    async fn test_read_file_content_returns_error_for_missing_file() {
        // Given: a path to a non-existent file
        // When: read_file_content is called
        // Then: returns Err(FileNotFound)
    }
```

### 2.3 Filesystem Service - `write_file_content`

```rust
    #[tokio::test]
    async fn test_write_file_content_saves_to_disk() {
        // Given: an existing .md file with content "# Old"
        // When: write_file_content is called with path and new content "# New"
        // Then: returns Ok(()), file on disk contains "# New"
    }

    #[tokio::test]
    async fn test_write_file_content_rejects_path_traversal() {
        // Given: a path containing "../" segments
        // When: write_file_content is called with "../../etc/passwd"
        // Then: returns Err(PathTraversal)
    }

    #[tokio::test]
    async fn test_write_file_content_creates_file_if_not_exists() {
        // Given: a path to a non-existent .md file in a valid directory
        // When: write_file_content is called
        // Then: returns Ok(()), file is created with the given content
    }

    #[tokio::test]
    async fn test_write_file_content_rejects_non_md_files() {
        // Given: a path ending in .ts
        // When: write_file_content is called
        // Then: returns Err(NotMarkdownFile)
    }
```

### 2.4 Filesystem Service - `create_file`

```rust
    #[tokio::test]
    async fn test_create_file_creates_empty_md() {
        // Given: a valid directory exists
        // When: create_file is called with "docs/new-doc.md"
        // Then: returns Ok(()), file exists on disk with empty content
    }

    #[tokio::test]
    async fn test_create_file_rejects_non_md_extension() {
        // Given: a valid directory
        // When: create_file is called with "docs/script.ts"
        // Then: returns Err(NotMarkdownFile)
    }

    #[tokio::test]
    async fn test_create_file_rejects_path_traversal() {
        // Given: a path containing "../"
        // When: create_file is called with "../../evil.md"
        // Then: returns Err(PathTraversal)
    }
```

### 2.5 Filesystem Service - `create_directory`

```rust
    #[tokio::test]
    async fn test_create_directory_creates_dir() {
        // Given: a valid parent directory
        // When: create_directory is called with "docs/new-section"
        // Then: returns Ok(()), directory exists on disk
    }

    #[tokio::test]
    async fn test_create_directory_rejects_path_traversal() {
        // Given: a path containing "../"
        // When: create_directory is called with "../../evil"
        // Then: returns Err(PathTraversal)
    }
```

### 2.6 Filesystem Service - `rename_entry`

```rust
    #[tokio::test]
    async fn test_rename_file_renames_and_returns_new_path() {
        // Given: "docs/old-name.md" exists
        // When: rename_entry is called with old_path="docs/old-name.md", new_name="new-name.md"
        // Then: returns Ok("docs/new-name.md"), old file gone, new file exists
    }

    #[tokio::test]
    async fn test_rename_file_rejects_non_md_new_name() {
        // Given: "docs/file.md" exists
        // When: rename_entry is called with new_name="file.txt"
        // Then: returns Err(NotMarkdownFile)
    }

    #[tokio::test]
    async fn test_rename_directory_works() {
        // Given: "docs/old-dir" exists
        // When: rename_entry is called with new_name="new-dir"
        // Then: returns Ok("docs/new-dir"), directory renamed
    }

    #[tokio::test]
    async fn test_rename_rejects_slash_in_name() {
        // Given: "docs/file.md" exists
        // When: rename_entry is called with new_name="sub/file.md"
        // Then: returns Err(InvalidName) - slashes not allowed in new_name
    }
```

### 2.7 Filesystem Service - `delete_entry`

```rust
    #[tokio::test]
    async fn test_delete_file_removes_from_disk() {
        // Given: "docs/to-delete.md" exists
        // When: delete_entry is called
        // Then: returns Ok(()), file no longer exists
    }

    #[tokio::test]
    async fn test_delete_empty_directory_succeeds() {
        // Given: "docs/empty-dir" exists and is empty
        // When: delete_entry is called
        // Then: returns Ok(()), directory removed
    }

    #[tokio::test]
    async fn test_delete_non_empty_directory_fails() {
        // Given: "docs/full-dir" contains files
        // When: delete_entry is called
        // Then: returns Err(DirectoryNotEmpty)
    }
```

## 3. Backend Integration Tests

**File:** `crates/server/tests/markdown_viewer_routes.rs`

```rust
#[tokio::test]
async fn test_get_markdown_tree_returns_filtered_tree() {
    // Given: a running server with a workspace containing mixed files
    // When: GET /api/filesystem/markdown-tree?path=/workspace/path
    // Then: 200 OK with tree containing only .md files and parent dirs
}

#[tokio::test]
async fn test_get_file_content_returns_content() {
    // Given: a running server with a workspace containing README.md
    // When: GET /api/filesystem/file-content?path=/workspace/path/README.md
    // Then: 200 OK with { content: "# ...", path: "README.md" }
}

#[tokio::test]
async fn test_get_file_content_rejects_invalid_path() {
    // Given: a running server
    // When: GET /api/filesystem/file-content?path=../../etc/passwd
    // Then: 400 Bad Request with error message
}

#[tokio::test]
async fn test_checkout_branch_switches_branch() {
    // Given: a running server with a workspace that has multiple branches
    // When: POST /api/task-attempts/:id/checkout-branch { repo_id, branch_name: "develop" }
    // Then: 200 OK, subsequent file tree reflects the new branch content
}

#[tokio::test]
async fn test_commit_and_push_creates_commit() {
    // Given: a running server with a workspace that has uncommitted changes
    // When: POST /api/task-attempts/:id/commit-and-push { repo_id, message: "test" }
    // Then: 200 OK with success response
}

#[tokio::test]
async fn test_merge_to_branch_merges_successfully() {
    // Given: a running server with a workspace, target branch "review" exists
    // When: POST /api/task-attempts/:id/merge-to-branch { repo_id, target_branch: "review" }
    // Then: 200 OK with success response
}

#[tokio::test]
async fn test_put_file_content_saves_file() {
    // Given: a running server with a workspace containing README.md
    // When: PUT /api/filesystem/file-content { path: "/workspace/path/README.md", content: "# Updated" }
    // Then: 200 OK, subsequent GET returns "# Updated"
}

#[tokio::test]
async fn test_put_file_content_rejects_invalid_path() {
    // Given: a running server
    // When: PUT /api/filesystem/file-content { path: "../../etc/passwd", content: "hacked" }
    // Then: 400 Bad Request with error message
}

#[tokio::test]
async fn test_post_create_file_creates_md_file() {
    // Given: a running server with a workspace
    // When: POST /api/filesystem/create-file { base_path: "/workspace", relative_path: "docs/new.md" }
    // Then: 200 OK, file exists, GET file-content returns empty string
}

#[tokio::test]
async fn test_post_create_directory_creates_dir() {
    // Given: a running server with a workspace
    // When: POST /api/filesystem/create-directory { base_path: "/workspace", relative_path: "docs/new-section" }
    // Then: 200 OK, directory exists in markdown-tree response
}

#[tokio::test]
async fn test_post_rename_renames_file() {
    // Given: a running server with "docs/old.md"
    // When: POST /api/filesystem/rename { base_path, old_path: "docs/old.md", new_name: "new.md" }
    // Then: 200 OK with { new_path: "docs/new.md" }, old path 404, new path 200
}

#[tokio::test]
async fn test_delete_entry_removes_file() {
    // Given: a running server with "docs/to-remove.md"
    // When: DELETE /api/filesystem/entry { base_path, relative_path: "docs/to-remove.md" }
    // Then: 200 OK, file no longer in markdown-tree
}

#[tokio::test]
async fn test_delete_entry_rejects_non_empty_dir() {
    // Given: a running server with "docs/" containing files
    // When: DELETE /api/filesystem/entry { base_path, relative_path: "docs" }
    // Then: 400 Bad Request with DirectoryNotEmpty error
}
```

## 4. Frontend Unit Tests - View Components

### 4.1 MdIcon

**File:** `frontend/src/components/markdown/__tests__/MdIcon.test.tsx`

```typescript
describe('MdIcon', () => {
  it('renders "MD" text content', () => {
    // Given: MdIcon component
    // When: rendered
    // Then: contains text "MD"
  });

  it('applies custom className', () => {
    // Given: MdIcon with className="h-6 w-6"
    // When: rendered
    // Then: root element has class "h-6 w-6"
  });

  it('uses default className when none provided', () => {
    // Given: MdIcon without className
    // When: rendered
    // Then: root element has default class "h-4 w-4"
  });
});
```

### 4.2 MarkdownFileTreeView

**File:** `frontend/src/components/markdown/__tests__/MarkdownFileTreeView.test.tsx`

```typescript
describe('MarkdownFileTreeView', () => {
  const mockEntries: FileTreeEntry[] = [
    {
      name: 'docs',
      path: 'docs',
      is_directory: true,
      children: [
        { name: 'README.md', path: 'docs/README.md', is_directory: false, children: [] },
      ],
    },
    { name: 'CHANGELOG.md', path: 'CHANGELOG.md', is_directory: false, children: [] },
  ];

  it('renders file tree with correct structure', () => {
    // Given: entries with directories and files
    // When: rendered with mockEntries
    // Then: "docs" directory and "CHANGELOG.md" file are visible
  });

  it('shows directory children when expanded', () => {
    // Given: expandedDirs = { 'docs': true }
    // When: rendered
    // Then: "README.md" under "docs" is visible
  });

  it('hides directory children when collapsed', () => {
    // Given: expandedDirs = { 'docs': false }
    // When: rendered
    // Then: "README.md" under "docs" is NOT visible
  });

  it('highlights the selected file', () => {
    // Given: selectedFilePath = 'CHANGELOG.md'
    // When: rendered
    // Then: CHANGELOG.md row has selected styling (bg-accent/10)
  });

  it('calls onSelectFile when file is clicked', () => {
    // Given: rendered with onSelectFile mock
    // When: user clicks on "CHANGELOG.md"
    // Then: onSelectFile called with 'CHANGELOG.md'
  });

  it('calls onToggleDir when directory is clicked', () => {
    // Given: rendered with onToggleDir mock
    // When: user clicks on "docs" directory
    // Then: onToggleDir called with 'docs'
  });

  it('does NOT call onSelectFile when directory is clicked', () => {
    // Given: rendered with onSelectFile mock
    // When: user clicks on "docs" directory
    // Then: onSelectFile is NOT called
  });

  it('shows empty state when entries is empty', () => {
    // Given: entries = []
    // When: rendered
    // Then: "No markdown files found" message is displayed
  });

  it('renders folder icons for directories', () => {
    // Given: entries with a directory
    // When: rendered
    // Then: FolderSimple icon is present
  });

  it('renders file icons for files', () => {
    // Given: entries with a file
    // When: rendered
    // Then: FileText icon is present
  });

  // Keyboard navigation tests
  it('moves selection down on ArrowDown key', () => {
    // Given: rendered with focus on first item
    // When: ArrowDown key pressed
    // Then: second item receives focus/selection
  });

  it('moves selection up on ArrowUp key', () => {
    // Given: rendered with focus on second item
    // When: ArrowUp key pressed
    // Then: first item receives focus/selection
  });

  it('selects file on Enter key', () => {
    // Given: rendered with focus on a file item
    // When: Enter key pressed
    // Then: onSelectFile called with that file's path
  });

  it('toggles directory on Enter key', () => {
    // Given: rendered with focus on a directory item
    // When: Enter key pressed
    // Then: onToggleDir called with that directory's path
  });

  // Context menu tests
  it('shows context menu with Rename and Delete on file right-click', () => {
    // Given: rendered with file entries
    // When: user right-clicks on "CHANGELOG.md"
    // Then: context menu appears with "Rename" and "Delete" items
    // And: "New File" and "New Folder" are NOT shown
  });

  it('shows context menu with all options on directory right-click', () => {
    // Given: rendered with directory entries
    // When: user right-clicks on "docs" directory
    // Then: context menu appears with "New File", "New Folder", separator, "Rename", "Delete"
  });

  it('shows context menu with New File and New Folder on empty area right-click', () => {
    // Given: rendered with some entries
    // When: user right-clicks on empty area below entries
    // Then: context menu appears with "New File" and "New Folder" only
  });

  it('calls onContextMenuAction with correct params on Rename click', () => {
    // Given: context menu open on "CHANGELOG.md"
    // When: user clicks "Rename"
    // Then: onContextMenuAction called with ('rename', 'CHANGELOG.md', false)
  });

  it('calls onContextMenuAction with correct params on Delete click', () => {
    // Given: context menu open on "docs" directory
    // When: user clicks "Delete"
    // Then: onContextMenuAction called with ('delete', 'docs', true)
  });

  it('calls onContextMenuAction with correct params on New File click', () => {
    // Given: context menu open on "docs" directory
    // When: user clicks "New File"
    // Then: onContextMenuAction called with ('new-file', 'docs', true)
  });

  it('calls onContextMenuAction with correct params on New Folder click', () => {
    // Given: context menu open on "docs" directory
    // When: user clicks "New Folder"
    // Then: onContextMenuAction called with ('new-folder', 'docs', true)
  });

  // Inline rename tests
  it('shows inline input when renamingPath matches a file', () => {
    // Given: renamingPath = 'CHANGELOG.md', renameValue = 'CHANGELOG.md'
    // When: rendered
    // Then: an <input> element is visible with value "CHANGELOG.md"
    // And: the normal file label is hidden
  });

  it('auto-focuses and selects name without extension in rename input', () => {
    // Given: renamingPath = 'docs/README.md'
    // When: rendered
    // Then: input is focused, selection covers "README" (not ".md")
  });

  it('calls onRenameSubmit on Enter in rename input', () => {
    // Given: renamingPath set, rendered with onRenameSubmit mock
    // When: user presses Enter in rename input
    // Then: onRenameSubmit called once
  });

  it('calls onRenameCancel on Escape in rename input', () => {
    // Given: renamingPath set, rendered with onRenameCancel mock
    // When: user presses Escape in rename input
    // Then: onRenameCancel called once
  });

  it('calls onRenameChange on typing in rename input', () => {
    // Given: renamingPath set, rendered with onRenameChange mock
    // When: user types "new-name.md"
    // Then: onRenameChange called with "new-name.md"
  });

  // Inline create tests
  it('shows inline input inside directory when creatingAt is set', () => {
    // Given: creatingAt = { parentPath: 'docs', type: 'file' }
    // When: rendered
    // Then: an <input> appears inside "docs" directory children
    // And: "docs" directory is expanded
  });

  it('calls onCreateSubmit on Enter in create input', () => {
    // Given: creatingAt set, rendered with onCreateSubmit mock
    // When: user types "notes.md" and presses Enter
    // Then: onCreateSubmit called once
  });

  it('calls onCreateCancel on Escape in create input', () => {
    // Given: creatingAt set, rendered with onCreateCancel mock
    // When: user presses Escape
    // Then: onCreateCancel called once
  });
});
```

### 4.3 BranchSelectorView

**File:** `frontend/src/components/markdown/__tests__/BranchSelectorView.test.tsx`

```typescript
describe('BranchSelectorView', () => {
  const mockBranches: GitBranch[] = [
    { name: 'main', is_current: true, is_remote: false, last_commit_date: new Date() },
    { name: 'develop', is_current: false, is_remote: false, last_commit_date: new Date() },
    { name: 'feature/docs', is_current: false, is_remote: false, last_commit_date: new Date() },
  ];

  it('renders dropdown with all branch names', () => {
    // Given: 3 branches
    // When: rendered
    // Then: dropdown has 3 options: main, develop, feature/docs
  });

  it('shows current branch as selected', () => {
    // Given: currentBranch = 'main'
    // When: rendered
    // Then: dropdown value is 'main'
  });

  it('calls onSelectBranch when selection changes', () => {
    // Given: rendered with onSelectBranch mock
    // When: user selects 'develop'
    // Then: onSelectBranch called with 'develop'
  });

  it('shows loading state', () => {
    // Given: isLoading = true
    // When: rendered
    // Then: dropdown is disabled and shows loading indicator
  });

  it('handles empty branch list', () => {
    // Given: branches = []
    // When: rendered
    // Then: dropdown shows "No branches" or is empty
  });
});
```

### 4.4 GitActionBarView

**File:** `frontend/src/components/markdown/__tests__/GitActionBarView.test.tsx`

```typescript
describe('GitActionBarView', () => {
  it('renders dropdown with 3 action options', () => {
    // Given: component rendered
    // When: checking dropdown options
    // Then: 3 options exist: "Commit & Push", "Merge Review", "Merge Stable"
  });

  it('shows selected action in dropdown', () => {
    // Given: selectedAction = 'merge-review'
    // When: rendered
    // Then: dropdown value is 'merge-review'
  });

  it('calls onSelectAction when dropdown changes', () => {
    // Given: rendered with onSelectAction mock
    // When: user selects 'merge-stable'
    // Then: onSelectAction called with 'merge-stable'
  });

  it('calls onExecute when DO! button is clicked', () => {
    // Given: rendered with onExecute mock
    // When: user clicks "DO!" button
    // Then: onExecute called once
  });

  it('disables DO! button when isExecuting', () => {
    // Given: isExecuting = true
    // When: rendered
    // Then: DO! button has disabled attribute
  });

  it('shows spinner in DO! button when isExecuting', () => {
    // Given: isExecuting = true
    // When: rendered
    // Then: SpinnerGap icon is visible inside button
  });
});
```

### 4.5 MarkdownEditorView

**File:** `frontend/src/components/markdown/__tests__/MarkdownEditorView.test.tsx`

```typescript
describe('MarkdownEditorView', () => {
  it('renders content in an editable textarea', () => {
    // Given: content = "# Hello\n\nWorld"
    // When: rendered
    // Then: <textarea> element contains the content
  });

  it('uses monospace font on textarea', () => {
    // Given: component rendered
    // When: checking textarea styles
    // Then: font-mono class is present
  });

  it('shows file path in header', () => {
    // Given: filePath = 'docs/README.md'
    // When: rendered
    // Then: "docs/README.md" text is visible in header
  });

  it('handles empty content', () => {
    // Given: content = ""
    // When: rendered
    // Then: renders without error, shows empty textarea
  });

  it('calls onContentChange when user types', () => {
    // Given: rendered with onContentChange mock
    // When: user types "new text" into textarea
    // Then: onContentChange called with updated content
  });

  it('shows Save button dimmed when no unsaved changes', () => {
    // Given: hasUnsavedChanges = false
    // When: rendered
    // Then: Save button has opacity-50 and is visually dimmed
  });

  it('shows Save button in brand color when has unsaved changes', () => {
    // Given: hasUnsavedChanges = true
    // When: rendered
    // Then: Save button has bg-brand class (orange)
  });

  it('calls onSave when Save button clicked', () => {
    // Given: hasUnsavedChanges = true, rendered with onSave mock
    // When: user clicks Save button
    // Then: onSave called once
  });

  it('does not call onSave when Save button clicked with no changes', () => {
    // Given: hasUnsavedChanges = false, rendered with onSave mock
    // When: user clicks Save button
    // Then: onSave NOT called
  });

  it('shows spinner in Save button when isSaving', () => {
    // Given: isSaving = true
    // When: rendered
    // Then: SpinnerGap icon visible in Save button area
  });

  it('disables textarea when isSaving', () => {
    // Given: isSaving = true
    // When: rendered
    // Then: textarea has disabled or readOnly attribute
  });

  it('handles Ctrl+S keyboard shortcut', () => {
    // Given: hasUnsavedChanges = true, rendered with onSave mock
    // When: user presses Ctrl+S (or Cmd+S on Mac)
    // Then: onSave called, default browser save prevented
  });

  it('does not trigger save on Ctrl+S when no changes', () => {
    // Given: hasUnsavedChanges = false, rendered with onSave mock
    // When: user presses Ctrl+S
    // Then: onSave NOT called (default still prevented)
  });

  it('shows unsaved indicator asterisk on filename when dirty', () => {
    // Given: hasUnsavedChanges = true, filePath = 'README.md'
    // When: rendered
    // Then: header shows "README.md*" or pulsing dot indicator
  });
});
```

### 4.6 MarkdownPreviewView

**File:** `frontend/src/components/markdown/__tests__/MarkdownPreviewView.test.tsx`

```typescript
describe('MarkdownPreviewView', () => {
  it('renders heading as <h1>', () => {
    // Given: content = "# My Title"
    // When: rendered
    // Then: <h1> element with text "My Title" exists
  });

  it('renders bold text', () => {
    // Given: content = "Some **bold** text"
    // When: rendered
    // Then: <strong> element with text "bold" exists
  });

  it('renders code blocks', () => {
    // Given: content = "```js\nconsole.log('hi')\n```"
    // When: rendered
    // Then: <pre><code> element exists with the code content
  });

  it('renders GFM tables', () => {
    // Given: content = "| A | B |\n|---|---|\n| 1 | 2 |"
    // When: rendered
    // Then: <table> element exists with proper cells
  });

  it('renders GFM task lists', () => {
    // Given: content = "- [x] Done\n- [ ] Todo"
    // When: rendered
    // Then: checkbox inputs exist, first is checked
  });

  it('renders links', () => {
    // Given: content = "[Click here](https://example.com)"
    // When: rendered
    // Then: <a> element with href="https://example.com" and text "Click here"
  });

  it('handles empty content', () => {
    // Given: content = ""
    // When: rendered
    // Then: renders without error
  });
});
```

## 5. Frontend Unit Tests - Hooks

**File:** `frontend/src/hooks/__tests__/useMarkdownViewer.test.ts`

```typescript
describe('useMarkdownTree', () => {
  it('fetches and returns file tree for given workspace and repo', () => {
    // Given: API returns a file tree
    // When: hook is called with valid attemptId and repoId
    // Then: data contains the file tree entries
  });

  it('returns error state on API failure', () => {
    // Given: API returns 500 error
    // When: hook is called
    // Then: isError is true, error contains message
  });

  it('refetches when repoId changes', () => {
    // Given: hook rendered with repoId "a"
    // When: repoId changes to "b"
    // Then: new API call is made with repoId "b"
  });
});

describe('useFileContent', () => {
  it('fetches content for given file path', () => {
    // Given: API returns { content: "# Hello", path: "README.md" }
    // When: hook is called with valid path
    // Then: data.content equals "# Hello"
  });

  it('caches results for same path', () => {
    // Given: hook called once with path "README.md"
    // When: hook called again with same path
    // Then: no new API call is made (cache hit)
  });

  it('is disabled when filePath is null', () => {
    // Given: filePath is null
    // When: hook is rendered
    // Then: no API call is made, data is undefined
  });
});

describe('useSaveFileContent', () => {
  it('mutation succeeds and returns saved path', () => {
    // Given: API save succeeds
    // When: mutate({ path: "README.md", content: "# Updated" })
    // Then: mutation returns success, data contains saved path
  });

  it('mutation invalidates file content query cache', () => {
    // Given: file content cached for "README.md"
    // When: save mutation succeeds for "README.md"
    // Then: useFileContent cache for "README.md" is invalidated
  });

  it('mutation handles error (permission denied)', () => {
    // Given: API returns 403 Forbidden
    // When: mutate is called
    // Then: onError callback fires with error message
  });

  it('tracks isSaving state during mutation', () => {
    // Given: save mutation is in flight
    // When: checking mutation state
    // Then: isPending is true
  });
});

describe('useSyncScroll', () => {
  it('scrolls preview when editor is scrolled', () => {
    // Given: editorRef and previewRef pointing to DOM elements
    //        editor scrollTop = 50, editor scrollHeight = 200, editor clientHeight = 100
    //        (maxScroll = 100, ratio = 50%)
    // When: onEditorScroll fires
    // Then: preview scrollTop is set to 50% of preview maxScroll
  });

  it('scrolls editor when preview is scrolled', () => {
    // Given: previewRef scroll position at 75%
    // When: onPreviewScroll fires
    // Then: editor scrollTop is set to 75% of editor maxScroll
  });

  it('does not create infinite scroll loop', () => {
    // Given: editor onScroll triggers preview scroll
    // When: preview scroll event fires as a result of programmatic scroll
    // Then: editor scroll is NOT triggered again (scrollSource guard prevents it)
  });

  it('resets scrollSource after requestAnimationFrame', () => {
    // Given: scrollSource = 'editor' after editor scroll
    // When: requestAnimationFrame callback fires
    // Then: scrollSource is reset to null, allowing future sync from either pane
  });

  it('handles zero maxScroll gracefully', () => {
    // Given: content is short, scrollHeight = clientHeight (maxScroll = 0)
    // When: onScroll fires
    // Then: no error, target scrollTop remains 0
  });

  it('returns stable handler references', () => {
    // Given: hook rendered
    // When: component re-renders
    // Then: onEditorScroll and onPreviewScroll refs are stable (useCallback)
  });
});

describe('useCreateFile', () => {
  it('mutation succeeds and invalidates tree query', () => {
    // Given: API create-file succeeds
    // When: mutate({ base_path: "/ws", relative_path: "docs/new.md" })
    // Then: mutation returns success
    // And: markdown tree query is invalidated (refetched)
  });

  it('mutation handles error (file already exists)', () => {
    // Given: API returns 409 Conflict
    // When: mutate is called
    // Then: onError callback fires with error message
  });
});

describe('useCreateDirectory', () => {
  it('mutation succeeds and invalidates tree query', () => {
    // Given: API create-directory succeeds
    // When: mutate({ base_path: "/ws", relative_path: "docs/new-section" })
    // Then: mutation returns success, tree query invalidated
  });
});

describe('useRenameEntry', () => {
  it('mutation succeeds and returns new path', () => {
    // Given: API rename succeeds
    // When: mutate({ base_path: "/ws", old_path: "docs/old.md", new_name: "new.md" })
    // Then: mutation returns { new_path: "docs/new.md" }
    // And: markdown tree query is invalidated
  });

  it('updates selectedFilePath if renamed file was selected', () => {
    // Given: selectedFilePath = "docs/old.md"
    // When: rename mutation succeeds with new_path = "docs/new.md"
    // Then: selectedFilePath is updated to "docs/new.md"
  });

  it('mutation handles error (invalid name)', () => {
    // Given: API returns 400 Bad Request
    // When: mutate is called with new_name containing "/"
    // Then: onError callback fires
  });
});

describe('useDeleteEntry', () => {
  it('mutation succeeds and invalidates tree query', () => {
    // Given: API delete succeeds
    // When: mutate({ base_path: "/ws", relative_path: "docs/file.md" })
    // Then: mutation returns success, tree query invalidated
  });

  it('clears selectedFilePath if deleted file was selected', () => {
    // Given: selectedFilePath = "docs/file.md"
    // When: delete mutation succeeds for "docs/file.md"
    // Then: selectedFilePath is set to null
  });

  it('mutation handles error (directory not empty)', () => {
    // Given: API returns 400 DirectoryNotEmpty
    // When: mutate is called for a non-empty dir
    // Then: onError callback fires with "Directory is not empty" message
  });
});

describe('useCheckoutBranch', () => {
  it('mutation succeeds and invalidates tree query', () => {
    // Given: API checkout succeeds
    // When: mutate({ repo_id: "x", branch_name: "develop" })
    // Then: mutation returns success
    // And: markdown tree query is invalidated
  });

  it('mutation handles error', () => {
    // Given: API checkout fails (branch not found)
    // When: mutate is called
    // Then: onError callback fires with error message
  });
});
```

## 6. Frontend Unit Tests - Actions

**File:** `frontend/src/components/ui-new/actions/__tests__/markdownAction.test.ts`

```typescript
describe('OpenMarkdownViewer action', () => {
  it('is visible when workspace exists', () => {
    // Given: actionContext with hasWorkspace = true
    // When: isVisible evaluated
    // Then: returns true
  });

  it('is hidden when no workspace', () => {
    // Given: actionContext with hasWorkspace = false
    // When: isVisible evaluated
    // Then: returns false
  });

  it('navigates to markdown viewer URL on execute', () => {
    // Given: ctx with currentWorkspaceId = "ws-123"
    // When: execute is called
    // Then: ctx.navigate called with "/workspaces/ws-123/markdown"
  });

  it('does nothing when no workspace ID', () => {
    // Given: ctx with currentWorkspaceId = null
    // When: execute is called
    // Then: ctx.navigate is NOT called
  });
});
```

## 7. E2E Tests (Playwright)

**File:** `frontend/e2e/markdown-viewer.spec.ts`

```typescript
import { test, expect } from '@playwright/test';

test.describe('Markdown Documentation Viewer', () => {

  test('MD icon is visible in ContextBar when workspace is open', async ({ page }) => {
    // Navigate to a workspace
    await page.goto('/workspaces/test-workspace-id');
    // Wait for ContextBar to load
    const mdButton = page.getByRole('button', { name: /markdown viewer/i });
    await expect(mdButton).toBeVisible();
  });

  test('clicking MD icon navigates to markdown viewer page', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id');
    await page.getByRole('button', { name: /markdown viewer/i }).click();
    await expect(page).toHaveURL(/\/workspaces\/test-workspace-id\/markdown/);
    // Verify page elements
    await expect(page.getByText('Markdown Viewer')).toBeVisible();
  });

  test('file tree shows only markdown files', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    // Wait for file tree to load
    const tree = page.getByRole('tree');
    await expect(tree).toBeVisible();
    // Verify .md files are shown
    await expect(page.getByText('README.md')).toBeVisible();
    // Verify non-markdown files are NOT shown
    await expect(page.getByText('.tsx')).not.toBeVisible();
    await expect(page.getByText('.rs')).not.toBeVisible();
  });

  test('selecting a file shows split view with editor and preview', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    // Click a markdown file
    await page.getByText('README.md').click();
    // Verify split view appears
    const editorPane = page.locator('[data-testid="markdown-editor-pane"]');
    const previewPane = page.locator('[data-testid="markdown-preview-pane"]');
    await expect(editorPane).toBeVisible();
    await expect(previewPane).toBeVisible();
    // Verify editor textarea contains markdown syntax
    const textarea = editorPane.locator('textarea');
    await expect(textarea).toBeVisible();
    await expect(textarea).toContainText('#');
    // Verify preview contains rendered HTML
    await expect(previewPane.locator('h1, h2, h3')).toBeVisible();
  });

  test('branch selector changes file tree content', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    // Open branch selector
    const branchSelect = page.getByLabel(/select.*branch/i);
    await expect(branchSelect).toBeVisible();
    // Note: full branch switching test requires specific test data setup
  });

  test('Commit & Push git action executes', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    // Select Commit & Push action
    const actionSelect = page.getByLabel(/select.*action/i);
    await actionSelect.selectOption('commit-push');
    // Click DO! button
    await page.getByRole('button', { name: /do!/i }).click();
    // Verify confirmation dialog appears
    await expect(page.getByText(/commit/i)).toBeVisible();
  });

  test('back button navigates to workspace', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    await page.getByRole('button', { name: /back/i }).click();
    await expect(page).toHaveURL(/\/workspaces\/test-workspace-id$/);
  });

  test('empty state shows when no markdown files', async ({ page }) => {
    // Navigate to workspace with no .md files (requires test setup)
    await page.goto('/workspaces/empty-workspace-id/markdown');
    await expect(page.getByText(/no markdown files/i)).toBeVisible();
  });

  test('editing content shows unsaved indicator and activates Save button', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    await page.getByText('README.md').click();
    const editorPane = page.locator('[data-testid="markdown-editor-pane"]');
    const textarea = editorPane.locator('textarea');
    const saveButton = page.getByRole('button', { name: /save/i });
    // Verify Save button is initially dimmed
    await expect(saveButton).toHaveClass(/opacity/);
    // Type into the textarea
    await textarea.fill('# Modified Content');
    // Verify Save button is now active (brand color)
    await expect(saveButton).not.toHaveClass(/opacity/);
  });

  test('Save button saves edited content', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    await page.getByText('README.md').click();
    const textarea = page.locator('[data-testid="markdown-editor-pane"] textarea');
    // Edit content
    await textarea.fill('# Saved Content');
    // Click Save
    await page.getByRole('button', { name: /save/i }).click();
    // Verify save completes (button returns to dimmed state)
    await expect(page.getByRole('button', { name: /save/i })).toHaveClass(/opacity/);
  });

  test('Ctrl+S keyboard shortcut saves the file', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    await page.getByText('README.md').click();
    const textarea = page.locator('[data-testid="markdown-editor-pane"] textarea');
    // Edit content
    await textarea.fill('# Shortcut Saved');
    // Press Ctrl+S
    await textarea.press('Control+s');
    // Verify save completes
    await expect(page.getByRole('button', { name: /save/i })).toHaveClass(/opacity/);
  });

  test('live preview updates as user types', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    await page.getByText('README.md').click();
    const textarea = page.locator('[data-testid="markdown-editor-pane"] textarea');
    const previewPane = page.locator('[data-testid="markdown-preview-pane"]');
    // Type new heading
    await textarea.fill('# Live Preview Test');
    // Verify preview updates with the new heading
    await expect(previewPane.locator('h1')).toContainText('Live Preview Test');
  });

  test('scrolling editor syncs preview scroll position', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    // Select a file with enough content to scroll
    await page.getByText('DOCUMENTATION.md').click();
    const editorPane = page.locator('[data-testid="markdown-editor-pane"]');
    const previewPane = page.locator('[data-testid="markdown-preview-pane"]');
    const textarea = editorPane.locator('textarea');
    // Scroll the editor to bottom
    await textarea.evaluate((el) => { el.scrollTop = el.scrollHeight; });
    // Wait for sync
    await page.waitForTimeout(100);
    // Verify preview is also scrolled near the bottom
    const previewScrollRatio = await previewPane.evaluate(
      (el) => el.scrollTop / (el.scrollHeight - el.clientHeight)
    );
    expect(previewScrollRatio).toBeGreaterThan(0.8);
  });

  test('scrolling preview syncs editor scroll position', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    await page.getByText('DOCUMENTATION.md').click();
    const editorPane = page.locator('[data-testid="markdown-editor-pane"]');
    const previewPane = page.locator('[data-testid="markdown-preview-pane"]');
    // Scroll the preview to 50%
    await previewPane.evaluate((el) => {
      el.scrollTop = (el.scrollHeight - el.clientHeight) * 0.5;
    });
    await page.waitForTimeout(100);
    // Verify editor is also scrolled near 50%
    const editorScrollRatio = await editorPane.locator('textarea').evaluate(
      (el) => el.scrollTop / (el.scrollHeight - el.clientHeight)
    );
    expect(editorScrollRatio).toBeCloseTo(0.5, 1);
  });

  test('right-click on file shows context menu with Rename and Delete', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    // Right-click on a file
    await page.getByText('README.md').click({ button: 'right' });
    // Verify context menu appears
    const menu = page.getByRole('menu');
    await expect(menu).toBeVisible();
    await expect(menu.getByText('Rename')).toBeVisible();
    await expect(menu.getByText('Delete')).toBeVisible();
    // Verify New File/Folder NOT shown for files
    await expect(menu.getByText('New File')).not.toBeVisible();
  });

  test('right-click on directory shows full context menu', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    await page.getByText('docs').click({ button: 'right' });
    const menu = page.getByRole('menu');
    await expect(menu.getByText('New File')).toBeVisible();
    await expect(menu.getByText('New Folder')).toBeVisible();
    await expect(menu.getByText('Rename')).toBeVisible();
    await expect(menu.getByText('Delete')).toBeVisible();
  });

  test('rename file via context menu', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    await page.getByText('CHANGELOG.md').click({ button: 'right' });
    await page.getByRole('menu').getByText('Rename').click();
    // Verify inline input appears
    const input = page.locator('[data-testid="rename-input"]');
    await expect(input).toBeVisible();
    await expect(input).toBeFocused();
    // Type new name and confirm
    await input.fill('HISTORY.md');
    await input.press('Enter');
    // Verify tree updates
    await expect(page.getByText('HISTORY.md')).toBeVisible();
    await expect(page.getByText('CHANGELOG.md')).not.toBeVisible();
  });

  test('delete file via context menu with confirmation', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    await page.getByText('CHANGELOG.md').click({ button: 'right' });
    await page.getByRole('menu').getByText('Delete').click();
    // Verify confirmation dialog
    await expect(page.getByText(/delete.*CHANGELOG\.md/i)).toBeVisible();
    await page.getByRole('button', { name: /delete/i }).click();
    // Verify file removed from tree
    await expect(page.getByText('CHANGELOG.md')).not.toBeVisible();
  });

  test('create new file via context menu on directory', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    await page.getByText('docs').click({ button: 'right' });
    await page.getByRole('menu').getByText('New File').click();
    // Verify inline input appears inside docs
    const input = page.locator('[data-testid="create-input"]');
    await expect(input).toBeVisible();
    await input.fill('notes');
    await input.press('Enter');
    // Verify new file appears in tree (auto-appends .md)
    await expect(page.getByText('notes.md')).toBeVisible();
  });

  test('keyboard navigation works in file tree', async ({ page }) => {
    await page.goto('/workspaces/test-workspace-id/markdown');
    // Focus the file tree
    const tree = page.getByRole('tree');
    await tree.focus();
    // Press ArrowDown
    await page.keyboard.press('ArrowDown');
    // Press Enter to select
    await page.keyboard.press('Enter');
    // Verify content loaded
    const editorPane = page.locator('[data-testid="markdown-editor-pane"]');
    await expect(editorPane).toBeVisible();
  });
});
```

## 8. Test Data Requirements

### Backend Tests
- Temporary directory with structure:
  ```
  temp/
    README.md (content: "# Test Project")
    src/
      main.rs (content: "fn main() {}")
    docs/
      guide.md (content: "## Guide")
      arch/
        decisions.md (content: "### ADR-001")
    empty_dir/
      config.json
  ```

### Frontend Tests
- Mock API responses with MSW (Mock Service Worker) or jest.fn()
- Mock data fixtures for FileTreeEntry[], GitBranch[], FileContentResponse, SaveFileContentResponse
- Mock `useSaveFileContent` mutation for editor tests (isPending, mutate, isSuccess states)

### E2E Tests
- Seed workspace with known repository containing:
  - Multiple .md files at various depths
  - Non-markdown files (to verify filtering)
  - Multiple branches (main, develop, review, stable)

## 9. Coverage Targets

| Area | Target | Metric |
|------|--------|--------|
| Backend services | 90% | Line coverage |
| Frontend views | 85% | Branch coverage |
| Frontend hooks | 80% | Branch coverage |
| Frontend containers | 70% | Line coverage (complex state) |
| E2E critical paths | 100% | All ACs covered |
| Overall | 80% min | Combined |

## 10. Test Execution Commands

```bash
# Backend tests
cargo test -p services --lib -- filesystem
cargo test -p server --test markdown_viewer_routes

# Frontend unit tests
cd frontend && pnpm vitest run src/components/markdown
cd frontend && pnpm vitest run src/hooks/__tests__/useMarkdownViewer

# Frontend E2E tests
cd frontend && pnpm playwright test e2e/markdown-viewer.spec.ts

# Full test suite
cargo test && cd frontend && pnpm vitest run && pnpm playwright test
```
