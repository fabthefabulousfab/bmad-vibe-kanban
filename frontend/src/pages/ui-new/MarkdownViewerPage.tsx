import { useSearchParams } from 'react-router-dom';
import { MarkdownViewerContainer } from '@/components/markdown/containers/MarkdownViewerContainer';

/**
 * MarkdownViewerPage - Page wrapper for the markdown viewer.
 * Reads basePath and repoId from query parameters.
 *
 * Route: /workspaces/:workspaceId/markdown
 * Query params: ?basePath=<path>&repoId=<id>
 */
export function MarkdownViewerPage() {
  const [searchParams] = useSearchParams();

  const basePath = searchParams.get('basePath');
  const repoId = searchParams.get('repoId');

  if (!basePath) {
    return (
      <div className="flex items-center justify-center h-full text-sm text-low">
        Missing basePath parameter. Open this page from a workspace context.
      </div>
    );
  }

  return (
    <MarkdownViewerContainer
      basePath={basePath}
      repoId={repoId}
    />
  );
}
