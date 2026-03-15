import type { Ref } from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import rehypeHighlight from 'rehype-highlight';

interface MarkdownPreviewViewProps {
  content: string;
  previewRef: Ref<HTMLDivElement>;
  onScroll: () => void;
}

/**
 * MarkdownPreviewView - Stateless rendered markdown HTML preview.
 * Uses react-markdown with GFM support and syntax highlighting.
 */
export function MarkdownPreviewView({
  content,
  previewRef,
  onScroll,
}: MarkdownPreviewViewProps) {
  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="flex items-center px-3 py-1.5 border-b border-secondary bg-secondary/20">
        <span className="text-sm text-low">Preview</span>
      </div>

      {/* Preview content */}
      <div
        ref={previewRef}
        className="flex-1 p-4 overflow-auto bg-primary"
        onScroll={onScroll}
        aria-label="Markdown preview"
      >
        <div className="prose prose-sm dark:prose-invert max-w-none">
          <ReactMarkdown
            remarkPlugins={[remarkGfm]}
            rehypePlugins={[rehypeHighlight]}
          >
            {content}
          </ReactMarkdown>
        </div>
      </div>
    </div>
  );
}
