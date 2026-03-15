import type { KeyboardEvent } from 'react';
import type { FileTreeEntry } from 'shared/types';
import { FolderSimple, FileText } from '@phosphor-icons/react';
import * as ContextMenu from '@radix-ui/react-context-menu';
import { cn } from '@/lib/utils';

export type TreeContextAction = 'rename' | 'delete' | 'new-file' | 'new-folder';

interface MarkdownFileTreeViewProps {
  entries: FileTreeEntry[];
  selectedFilePath: string | null;
  expandedDirs: Record<string, boolean>;
  renamingPath: string | null;
  renameValue: string;
  creatingAt: { parentPath: string; type: 'file' | 'directory' } | null;
  createValue: string;
  onSelectFile: (path: string) => void;
  onToggleDir: (path: string) => void;
  onContextMenuAction: (
    action: TreeContextAction,
    targetPath: string,
    isDirectory: boolean
  ) => void;
  onRenameChange: (value: string) => void;
  onRenameSubmit: () => void;
  onRenameCancel: () => void;
  onCreateChange: (value: string) => void;
  onCreateSubmit: () => void;
  onCreateCancel: () => void;
}

/**
 * MarkdownFileTreeView - Stateless recursive file tree filtered to .md files.
 * Supports keyboard navigation, right-click context menu, inline rename/create.
 */
export function MarkdownFileTreeView({
  entries,
  selectedFilePath,
  expandedDirs,
  renamingPath,
  renameValue,
  creatingAt,
  createValue,
  onSelectFile,
  onToggleDir,
  onContextMenuAction,
  onRenameChange,
  onRenameSubmit,
  onRenameCancel,
  onCreateChange,
  onCreateSubmit,
  onCreateCancel,
}: MarkdownFileTreeViewProps) {
  if (entries.length === 0) {
    return (
      <div className="flex items-center justify-center h-full text-sm text-low p-4">
        No markdown files found
      </div>
    );
  }

  return (
    <div
      className="flex-1 overflow-auto"
      role="tree"
      aria-label="Markdown file tree"
      tabIndex={0}
      onKeyDown={(e: KeyboardEvent<HTMLDivElement>) => {
        if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
          e.preventDefault();
          // Collect all visible items for keyboard navigation
          const allItems = document.querySelectorAll('[role="treeitem"]');
          const currentIndex = Array.from(allItems).findIndex(
            (item) => item === document.activeElement
          );
          const nextIndex =
            e.key === 'ArrowDown'
              ? Math.min(currentIndex + 1, allItems.length - 1)
              : Math.max(currentIndex - 1, 0);
          (allItems[nextIndex] as HTMLElement)?.focus();
        }
      }}
    >
      {entries.map((entry) => (
        <TreeItem
          key={entry.path}
          entry={entry}
          depth={0}
          selectedFilePath={selectedFilePath}
          expandedDirs={expandedDirs}
          renamingPath={renamingPath}
          renameValue={renameValue}
          creatingAt={creatingAt}
          createValue={createValue}
          onSelectFile={onSelectFile}
          onToggleDir={onToggleDir}
          onContextMenuAction={onContextMenuAction}
          onRenameChange={onRenameChange}
          onRenameSubmit={onRenameSubmit}
          onRenameCancel={onRenameCancel}
          onCreateChange={onCreateChange}
          onCreateSubmit={onCreateSubmit}
          onCreateCancel={onCreateCancel}
        />
      ))}
    </div>
  );
}

interface TreeItemProps {
  entry: FileTreeEntry;
  depth: number;
  selectedFilePath: string | null;
  expandedDirs: Record<string, boolean>;
  renamingPath: string | null;
  renameValue: string;
  creatingAt: { parentPath: string; type: 'file' | 'directory' } | null;
  createValue: string;
  onSelectFile: (path: string) => void;
  onToggleDir: (path: string) => void;
  onContextMenuAction: (
    action: TreeContextAction,
    targetPath: string,
    isDirectory: boolean
  ) => void;
  onRenameChange: (value: string) => void;
  onRenameSubmit: () => void;
  onRenameCancel: () => void;
  onCreateChange: (value: string) => void;
  onCreateSubmit: () => void;
  onCreateCancel: () => void;
}

function TreeItem({
  entry,
  depth,
  selectedFilePath,
  expandedDirs,
  renamingPath,
  renameValue,
  creatingAt,
  createValue,
  onSelectFile,
  onToggleDir,
  onContextMenuAction,
  onRenameChange,
  onRenameSubmit,
  onRenameCancel,
  onCreateChange,
  onCreateSubmit,
  onCreateCancel,
}: TreeItemProps) {
  const isSelected = selectedFilePath === entry.path;
  const isExpanded = entry.is_directory && expandedDirs[entry.path] !== false;
  const isRenaming = renamingPath === entry.path;
  const isCreatingHere =
    creatingAt !== null && creatingAt.parentPath === entry.path;

  const handleClick = () => {
    if (entry.is_directory) {
      onToggleDir(entry.path);
    } else {
      onSelectFile(entry.path);
    }
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLDivElement>) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      handleClick();
    }
  };

  const contextMenuItems = entry.is_directory
    ? (['new-file', 'new-folder', 'rename', 'delete'] as TreeContextAction[])
    : (['rename', 'delete'] as TreeContextAction[]);

  const contextMenuLabels: Record<TreeContextAction, string> = {
    rename: 'Rename',
    delete: 'Delete',
    'new-file': 'New File',
    'new-folder': 'New Folder',
  };

  return (
    <>
      <ContextMenu.Root>
        <ContextMenu.Trigger asChild>
          <div
            role="treeitem"
            tabIndex={-1}
            className={cn(
              'flex items-center gap-1 px-2 py-0.5 cursor-pointer text-sm',
              'hover:bg-secondary/50 transition-colors',
              isSelected && 'bg-accent/10 border-l-2 border-accent',
              !isSelected && 'border-l-2 border-transparent'
            )}
            style={{ paddingLeft: `${depth * 16 + 8}px` }}
            onClick={handleClick}
            onKeyDown={handleKeyDown}
            aria-selected={isSelected}
            aria-expanded={entry.is_directory ? isExpanded : undefined}
          >
            {entry.is_directory ? (
              <FolderSimple className="size-icon-sm text-low flex-shrink-0" />
            ) : (
              <FileText className="size-icon-sm text-low flex-shrink-0" />
            )}
            {isRenaming ? (
              <input
                type="text"
                className="flex-1 px-1 text-sm bg-secondary border border-accent rounded text-normal focus:outline-none"
                value={renameValue}
                onChange={(e) => onRenameChange(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    e.preventDefault();
                    onRenameSubmit();
                  } else if (e.key === 'Escape') {
                    e.preventDefault();
                    onRenameCancel();
                  }
                  e.stopPropagation();
                }}
                onClick={(e) => e.stopPropagation()}
                autoFocus
              />
            ) : (
              <span className="truncate text-normal">{entry.name}</span>
            )}
          </div>
        </ContextMenu.Trigger>

        <ContextMenu.Portal>
          <ContextMenu.Content className="min-w-[160px] bg-secondary border border-secondary rounded shadow-lg p-1 z-50">
            {contextMenuItems.map((action) => (
              <ContextMenu.Item
                key={action}
                className={cn(
                  'flex items-center px-2 py-1.5 text-sm rounded cursor-pointer',
                  'text-normal hover:bg-accent/10 outline-none',
                  action === 'delete' && 'text-error hover:bg-error/10'
                )}
                onSelect={() =>
                  onContextMenuAction(action, entry.path, entry.is_directory)
                }
              >
                {contextMenuLabels[action]}
              </ContextMenu.Item>
            ))}
          </ContextMenu.Content>
        </ContextMenu.Portal>
      </ContextMenu.Root>

      {/* Children (if expanded directory) */}
      {entry.is_directory && isExpanded && (
        <>
          {entry.children.map((child) => (
            <TreeItem
              key={child.path}
              entry={child}
              depth={depth + 1}
              selectedFilePath={selectedFilePath}
              expandedDirs={expandedDirs}
              renamingPath={renamingPath}
              renameValue={renameValue}
              creatingAt={creatingAt}
              createValue={createValue}
              onSelectFile={onSelectFile}
              onToggleDir={onToggleDir}
              onContextMenuAction={onContextMenuAction}
              onRenameChange={onRenameChange}
              onRenameSubmit={onRenameSubmit}
              onRenameCancel={onRenameCancel}
              onCreateChange={onCreateChange}
              onCreateSubmit={onCreateSubmit}
              onCreateCancel={onCreateCancel}
            />
          ))}
          {/* Inline create input */}
          {isCreatingHere && (
            <div
              className="flex items-center gap-1 px-2 py-0.5"
              style={{ paddingLeft: `${(depth + 1) * 16 + 8}px` }}
            >
              {creatingAt.type === 'directory' ? (
                <FolderSimple className="size-icon-sm text-low flex-shrink-0" />
              ) : (
                <FileText className="size-icon-sm text-low flex-shrink-0" />
              )}
              <input
                type="text"
                className="flex-1 px-1 text-sm bg-secondary border border-accent rounded text-normal focus:outline-none"
                value={createValue}
                onChange={(e) => onCreateChange(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    e.preventDefault();
                    onCreateSubmit();
                  } else if (e.key === 'Escape') {
                    e.preventDefault();
                    onCreateCancel();
                  }
                }}
                placeholder={
                  creatingAt.type === 'file' ? 'filename.md' : 'folder name'
                }
                autoFocus
              />
            </div>
          )}
        </>
      )}
    </>
  );
}
