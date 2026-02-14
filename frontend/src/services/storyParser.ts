/**
 * Story Parser Service
 *
 * Parses BMAD story markdown files to extract metadata and content
 * for import into Vibe Kanban.
 */

/**
 * Parsed story data structure
 */
export interface ParsedStory {
  /**
   * W-E-S identifier (e.g., "1-1-0")
   */
  wes: string;

  /**
   * Story title from H1 heading
   */
  title: string;

  /**
   * Full markdown content (excluding H1 title line)
   */
  description: string;

  /**
   * Sequential number for task ordering
   */
  sequenceNumber: number;
}

/**
 * Story file information
 */
export interface StoryFile {
  filename: string;
  wes: string;
  path: string;
}

/**
 * Extract W-E-S identifier from filename
 *
 * @param filename - Story filename (e.g., "1-1-0-quick-spec.md")
 * @returns W-E-S string (e.g., "1-1-0") or null if invalid
 */
export function extractWesFromFilename(filename: string): string | null {
  // Match pattern: {number}-{number}-{number}-...
  const wesMatch = filename.match(/^(\d+-\d+-\d+)-.+\.md$/);
  return wesMatch ? wesMatch[1] : null;
}

/**
 * Parse story markdown content
 *
 * @param markdown - Raw markdown content
 * @returns Parsed story data
 */
export function parseStoryMarkdown(markdown: string, sequenceNumber: number): ParsedStory {
  const lines = markdown.split('\n');

  // Extract title from first H1 heading
  let title = '';
  let descriptionStartIndex = 0;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line.startsWith('# ')) {
      const rawTitle = line.substring(2).trim();
      // Remove "Story X-X/X: " prefix if present
      title = rawTitle.replace(/^Story\s+\d+-\d+\/\d+:\s*/i, '');
      descriptionStartIndex = i + 1;
      break;
    }
  }

  // Fallback: use filename as title if no H1 found
  if (!title) {
    title = 'Untitled Story';
  }

  // Extract W-E-S from content (Wave/Epic/Story metadata)
  let wes = '';
  const wesLineMatch = markdown.match(/\*\*Wave:\*\*\s*(\d+)\s*\|\s*\*\*Epic:\*\*\s*(\d+)\s*\|\s*\*\*Story:\*\*\s*(\d+)/);
  if (wesLineMatch) {
    wes = `${wesLineMatch[1]}-${wesLineMatch[2]}-${wesLineMatch[3]}`;
  }

  // Extract description (everything after title)
  const description = lines.slice(descriptionStartIndex).join('\n').trim();

  return {
    wes,
    title,
    description: wes ? `[Original ID: ${wes}]\n\n${description}` : description,
    sequenceNumber,
  };
}

/**
 * Sort story files by W-E-S order
 *
 * @param files - Array of story files
 * @returns Sorted array
 */
export function sortStoriesByWes(files: StoryFile[]): StoryFile[] {
  return files.sort((a, b) => {
    const [aw, ae, as] = a.wes.split('-').map(Number);
    const [bw, be, bs] = b.wes.split('-').map(Number);

    if (aw !== bw) return aw - bw;
    if (ae !== be) return ae - be;
    return as - bs;
  });
}

/**
 * Fetch story markdown file from public directory
 *
 * @param workflowDir - Workflow directory name (e.g., "quick-flow")
 * @param filename - Story filename
 * @returns Markdown content
 */
export async function fetchStoryFile(workflowDir: string, filename: string): Promise<string> {
  try {
    const response = await fetch(`/stories/${workflowDir}/${filename}`);

    if (!response.ok) {
      // Differentiate between HTTP errors
      if (response.status === 404) {
        throw new Error(`Story file not found: ${filename}`);
      } else if (response.status >= 500) {
        throw new Error(`Server error loading story: ${filename} (${response.status})`);
      } else {
        throw new Error(`Failed to load story: ${filename} (HTTP ${response.status})`);
      }
    }

    return response.text();
  } catch (error) {
    // Network errors (offline, timeout, CORS, etc.)
    if (error instanceof TypeError) {
      throw new Error(`Network error: Cannot load story ${filename}. Check your connection.`);
    }
    // Re-throw HTTP errors
    throw error;
  }
}

/**
 * Discover all story files in a workflow directory
 *
 * @param workflowDir - Workflow directory name
 * @returns Array of story file information
 */
export async function discoverStoryFiles(workflowDir: string): Promise<StoryFile[]> {
  // IMPORTANT: These manifests are hardcoded because browsers cannot list directory contents via HTTP.
  // When story files are added/removed/renamed in /stories/, run:
  //   ./scripts/sync-story-manifests.sh
  // to regenerate these manifests and update this file.
  //
  // TODO: Consider build-time generation or server-side endpoint for dynamic discovery.

  const workflowManifests: Record<string, string[]> = {
    'quick-flow': [
      '1-1-0-quick-spec.md',
      '1-1-1-regression-analysis.md',
      '1-2-0-atdd.md',
      '1-2-1-dev.md',
      '1-2-2-test-review.md',
      '1-2-3-code-review.md',
      '1-2-4-trace.md',
    ],
    'debug': [
      '1-1-0-quick-spec.md',
      '1-1-1-regression-analysis.md',
      '1-2-0-atdd.md',
      '1-2-1-dev.md',
      '1-2-2-test-review.md',
      '1-2-3-code-review.md',
      '1-2-4-trace.md',
    ],
    'document-project': [
      '0-1-0-analyze-codebase.md',
      '0-1-1-import-docs.md',
      '0-1-2-reconcile-docs.md',
      '2-1-0-prd-from-code.md',
      '3-1-0-architecture.md',
      '3-1-1-test-design.md',
      '3-1-2-nfr-assessment.md',
      '3-1-3-transition.md',
    ],
    'workflow-complet': [
      '1-1-0-brainstorm.md',
      '1-1-1-research.md',
      '1-1-2-product-brief.md',
      '2-1-0-prd.md',
      '2-1-1-ux-design.md',
      '3-1-0-architecture.md',
      '3-1-1-test-design.md',
      '3-1-2-nfr-assessment.md',
      '3-2-0-epics-stories.md',
      '3-2-1-sprint-planning.md',
      '4-1-0-sprint0-framework.md',
      '4-1-1-sprint0-ci.md',
      '4-2-0-prepare-stories.md',
      '4-2-1-renumber-waves.md',
      '4-2-2-import-vibe-kanban.md',
      '5-1-0-release-trace.md',
    ],
  };

  const filenames = workflowManifests[workflowDir] || [];

  const storyFiles: StoryFile[] = filenames
    .map((filename) => {
      const wes = extractWesFromFilename(filename);
      return wes ? {
        filename,
        wes,
        path: `/stories/${workflowDir}/${filename}`,
      } : null;
    })
    .filter((file): file is StoryFile => file !== null);

  return sortStoriesByWes(storyFiles);
}
