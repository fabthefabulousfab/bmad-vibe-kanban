import { useState, useRef, useCallback, useEffect } from 'react';
import type { TreeContextAction } from '../views/MarkdownFileTreeView';
import type { GitAction } from '../views/GitActionBarView';
import { MarkdownFileTreeView } from '../views/MarkdownFileTreeView';
import { MarkdownEditorView } from '../views/MarkdownEditorView';
import { MarkdownPreviewView } from '../views/MarkdownPreviewView';
import { BranchSelectorView } from '../views/BranchSelectorView';
import { GitActionBarView } from '../views/GitActionBarView';
import {
  useMarkdownTree,
  useFileContent,
  useSaveFileContent,
  useCreateFile,
  useCreateDirectory,
  useRenameEntry,
  useDeleteEntry,
  useBranches,
  useSyncScroll,
} from '@/hooks/useMarkdownViewer';

interface MarkdownViewerContainerProps {
  /** Absolute path to the workspace/repo root */
  basePath: string;
  /** Repository ID for git operations (optional) */
  repoId?: string | null;
}

/**
 * MarkdownViewerContainer - Orchestrates all state for the markdown viewer.
 * Manages file selection, editing, saving, tree CRUD, branch selection,
 * and git actions. Delegates rendering to stateless view components.
 */
export function MarkdownViewerContainer({
  basePath,
  repoId = null,
}: MarkdownViewerContainerProps) {
  // --- File tree state ---
  const [selectedFilePath, setSelectedFilePath] = useState<string | null>(null);
  const [expandedDirs, setExpandedDirs] = useState<Record<string, boolean>>({});
  const [renamingPath, setRenamingPath] = useState<string | null>(null);
  const [renameValue, setRenameValue] = useState('');
  const [creatingAt, setCreatingAt] = useState<{
    parentPath: string;
    type: 'file' | 'directory';
  } | null>(null);
  const [createValue, setCreateValue] = useState('');

  // --- Editor state ---
  const [editedContent, setEditedContent] = useState<string | null>(null);

  // --- Git action state ---
  const [selectedGitAction, setSelectedGitAction] =
    useState<GitAction>('commit-push');
  const [isExecutingGitAction, setIsExecutingGitAction] = useState(false);

  // --- Refs for scroll sync ---
  const editorRef = useRef<HTMLTextAreaElement | null>(null);
  const previewRef = useRef<HTMLDivElement | null>(null);
  const { onEditorScroll, onPreviewScroll } = useSyncScroll(
    editorRef,
    previewRef
  );

  // --- Data queries ---
  const { data: tree = [], isLoading: isTreeLoading } =
    useMarkdownTree(basePath);
  const { data: fileData, isLoading: isFileLoading } = useFileContent(
    basePath,
    selectedFilePath
  );
  const { data: branches = [], isLoading: isBranchesLoading } =
    useBranches(repoId);

  // --- Mutations ---
  const saveFileMutation = useSaveFileContent(basePath);
  const createFileMutation = useCreateFile(basePath);
  const createDirectoryMutation = useCreateDirectory(basePath);
  const renameEntryMutation = useRenameEntry(basePath);
  const deleteEntryMutation = useDeleteEntry(basePath);

  // --- Derived state ---
  const currentContent = editedContent ?? fileData?.content ?? '';
  const hasUnsavedChanges =
    editedContent !== null && editedContent !== (fileData?.content ?? '');
  const currentBranch =
    branches.find((b) => b.is_current)?.name ?? '';

  // When file data loads or changes, reset the edited content
  useEffect(() => {
    setEditedContent(null);
  }, [fileData?.content]);

  // --- Handlers ---
  const handleSelectFile = useCallback((path: string) => {
    setSelectedFilePath(path);
    setEditedContent(null);
  }, []);

  const handleToggleDir = useCallback((path: string) => {
    setExpandedDirs((prev) => ({
      ...prev,
      [path]: prev[path] === false ? true : prev[path] === undefined ? false : !prev[path],
    }));
  }, []);

  const handleSave = useCallback(() => {
    if (!selectedFilePath || editedContent === null) return;
    saveFileMutation.mutate({
      filePath: selectedFilePath,
      content: editedContent,
    });
  }, [selectedFilePath, editedContent, saveFileMutation]);

  const handleContextMenuAction = useCallback(
    (action: TreeContextAction, targetPath: string, _isDirectory: boolean) => {
      switch (action) {
        case 'rename':
          setRenamingPath(targetPath);
          setRenameValue(targetPath.split('/').pop() ?? '');
          break;
        case 'delete':
          if (
            window.confirm(
              `Are you sure you want to delete "${targetPath.split('/').pop()}"?`
            )
          ) {
            deleteEntryMutation.mutate(targetPath, {
              onSuccess: () => {
                if (selectedFilePath === targetPath) {
                  setSelectedFilePath(null);
                  setEditedContent(null);
                }
              },
            });
          }
          break;
        case 'new-file':
          setCreatingAt({ parentPath: targetPath, type: 'file' });
          setCreateValue('');
          // Ensure the directory is expanded
          setExpandedDirs((prev) => ({ ...prev, [targetPath]: true }));
          break;
        case 'new-folder':
          setCreatingAt({ parentPath: targetPath, type: 'directory' });
          setCreateValue('');
          setExpandedDirs((prev) => ({ ...prev, [targetPath]: true }));
          break;
      }
    },
    [deleteEntryMutation, selectedFilePath]
  );

  const handleRenameSubmit = useCallback(() => {
    if (!renamingPath || !renameValue.trim()) {
      setRenamingPath(null);
      return;
    }
    renameEntryMutation.mutate(
      { oldPath: renamingPath, newName: renameValue.trim() },
      {
        onSuccess: (response) => {
          // If the renamed file was selected, update the selection
          if (selectedFilePath === renamingPath) {
            setSelectedFilePath(response.new_path);
          }
          setRenamingPath(null);
        },
        onError: () => {
          setRenamingPath(null);
        },
      }
    );
  }, [renamingPath, renameValue, renameEntryMutation, selectedFilePath]);

  const handleRenameCancel = useCallback(() => {
    setRenamingPath(null);
    setRenameValue('');
  }, []);

  const handleCreateSubmit = useCallback(() => {
    if (!creatingAt || !createValue.trim()) {
      setCreatingAt(null);
      return;
    }
    const relativePath = creatingAt.parentPath
      ? `${creatingAt.parentPath}/${createValue.trim()}`
      : createValue.trim();

    if (creatingAt.type === 'file') {
      const finalPath = relativePath.endsWith('.md')
        ? relativePath
        : `${relativePath}.md`;
      createFileMutation.mutate(finalPath, {
        onSuccess: () => {
          setCreatingAt(null);
          setCreateValue('');
          // Auto-select the new file
          setSelectedFilePath(finalPath);
        },
        onError: () => {
          setCreatingAt(null);
        },
      });
    } else {
      createDirectoryMutation.mutate(relativePath, {
        onSuccess: () => {
          setCreatingAt(null);
          setCreateValue('');
        },
        onError: () => {
          setCreatingAt(null);
        },
      });
    }
  }, [creatingAt, createValue, createFileMutation, createDirectoryMutation]);

  const handleCreateCancel = useCallback(() => {
    setCreatingAt(null);
    setCreateValue('');
  }, []);

  const handleSelectBranch = useCallback(
    (_branchName: string) => {
      // Branch checkout would require a workspace-specific API call
      // For now this is a placeholder - the tech spec mentions checkout endpoint
      // which would be implemented via the workspace/repo git service
      console.warn('Branch checkout not yet implemented for standalone markdown viewer');
    },
    []
  );

  const handleExecuteGitAction = useCallback(() => {
    setIsExecutingGitAction(true);
    // Git actions would be implemented via workspace git APIs
    // For now, simulate a brief loading state
    console.warn(`Git action "${selectedGitAction}" not yet implemented for standalone markdown viewer`);
    setTimeout(() => {
      setIsExecutingGitAction(false);
    }, 1000);
  }, [selectedGitAction]);

  return (
    <div className="flex h-full bg-primary">
      {/* Left sidebar - File tree */}
      <div className="flex flex-col w-64 min-w-[200px] border-r border-secondary">
        {/* Branch selector */}
        {repoId && (
          <BranchSelectorView
            branches={branches}
            currentBranch={currentBranch}
            onSelectBranch={handleSelectBranch}
            isLoading={isBranchesLoading}
          />
        )}

        {/* File tree */}
        {isTreeLoading ? (
          <div className="flex items-center justify-center h-32 text-sm text-low">
            Loading files...
          </div>
        ) : (
          <MarkdownFileTreeView
            entries={tree}
            selectedFilePath={selectedFilePath}
            expandedDirs={expandedDirs}
            renamingPath={renamingPath}
            renameValue={renameValue}
            creatingAt={creatingAt}
            createValue={createValue}
            onSelectFile={handleSelectFile}
            onToggleDir={handleToggleDir}
            onContextMenuAction={handleContextMenuAction}
            onRenameChange={setRenameValue}
            onRenameSubmit={handleRenameSubmit}
            onRenameCancel={handleRenameCancel}
            onCreateChange={setCreateValue}
            onCreateSubmit={handleCreateSubmit}
            onCreateCancel={handleCreateCancel}
          />
        )}

        {/* Git action bar */}
        {repoId && (
          <GitActionBarView
            selectedAction={selectedGitAction}
            onSelectAction={setSelectedGitAction}
            onExecute={handleExecuteGitAction}
            isExecuting={isExecutingGitAction}
          />
        )}
      </div>

      {/* Main area - Editor + Preview */}
      {selectedFilePath ? (
        isFileLoading ? (
          <div className="flex-1 flex items-center justify-center text-sm text-low">
            Loading file...
          </div>
        ) : (
          <div className="flex-1 flex">
            {/* Editor pane */}
            <div className="flex-1 min-w-0">
              <MarkdownEditorView
                content={currentContent}
                filePath={selectedFilePath}
                hasUnsavedChanges={hasUnsavedChanges}
                isSaving={saveFileMutation.isPending}
                onContentChange={setEditedContent}
                onSave={handleSave}
                editorRef={editorRef}
                onScroll={onEditorScroll}
              />
            </div>

            {/* Preview pane */}
            <div className="flex-1 min-w-0">
              <MarkdownPreviewView
                content={currentContent}
                previewRef={previewRef}
                onScroll={onPreviewScroll}
              />
            </div>
          </div>
        )
      ) : (
        <div className="flex-1 flex items-center justify-center text-sm text-low">
          Select a markdown file to begin editing
        </div>
      )}
    </div>
  );
}
