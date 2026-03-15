import type { Ref } from 'react';
import { FloppyDisk } from '@phosphor-icons/react';
import { cn } from '@/lib/utils';

interface MarkdownEditorViewProps {
  content: string;
  filePath: string;
  hasUnsavedChanges: boolean;
  isSaving: boolean;
  onContentChange: (newContent: string) => void;
  onSave: () => void;
  editorRef: Ref<HTMLTextAreaElement>;
  onScroll: () => void;
}

/**
 * MarkdownEditorView - Stateless editable textarea for raw markdown.
 * Shows file name in header with Save button. Supports Ctrl+S/Cmd+S.
 */
export function MarkdownEditorView({
  content,
  filePath,
  hasUnsavedChanges,
  isSaving,
  onContentChange,
  onSave,
  editorRef,
  onScroll,
}: MarkdownEditorViewProps) {
  const fileName = filePath.split('/').pop() ?? filePath;

  return (
    <div className="flex flex-col h-full border-r border-secondary">
      {/* Header */}
      <div className="flex items-center justify-between px-3 py-1.5 border-b border-secondary bg-secondary/20">
        <span className="text-sm text-low truncate">
          {fileName}
          {hasUnsavedChanges && (
            <span className="text-accent ml-1" title="Unsaved changes">
              *
            </span>
          )}
        </span>
        <button
          className={cn(
            'flex items-center gap-1 px-2 py-1 text-xs rounded transition-colors',
            hasUnsavedChanges
              ? 'bg-accent text-white hover:bg-accent/90'
              : 'bg-secondary/50 text-low cursor-default'
          )}
          onClick={onSave}
          disabled={!hasUnsavedChanges || isSaving}
          aria-label="Save file"
          title="Save (Ctrl+S)"
        >
          <FloppyDisk className="size-icon-sm" />
          {isSaving ? 'Saving...' : 'Save'}
        </button>
      </div>

      {/* Editor textarea */}
      <textarea
        ref={editorRef}
        className={cn(
          'flex-1 w-full p-3 resize-none',
          'bg-secondary/20 text-normal',
          'font-mono text-sm leading-relaxed',
          'focus:outline-none',
          'overflow-auto'
        )}
        value={content}
        onChange={(e) => onContentChange(e.target.value)}
        onScroll={onScroll}
        onKeyDown={(e) => {
          if ((e.metaKey || e.ctrlKey) && e.key === 's') {
            e.preventDefault();
            if (hasUnsavedChanges) {
              onSave();
            }
          }
        }}
        spellCheck={false}
        aria-label="Markdown editor"
      />
    </div>
  );
}
