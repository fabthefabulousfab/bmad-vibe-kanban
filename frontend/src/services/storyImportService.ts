/**
 * Story Import Service
 *
 * Handles importing BMAD workflow stories into Vibe Kanban projects.
 * Orchestrates story file discovery, parsing, and task creation.
 */

import { tasksApi } from '@/lib/api';
import type { CreateTask } from 'shared/types';
import {
  discoverStoryFiles,
  fetchStoryFile,
  parseStoryMarkdown,
  type ParsedStory,
} from './storyParser';

/**
 * Import progress callback data
 */
export interface ImportProgress {
  /**
   * Total number of stories to import
   */
  total: number;

  /**
   * Current story being processed (1-indexed)
   */
  current: number;

  /**
   * Title of current story
   */
  currentStory: string;

  /**
   * Number of stories successfully imported
   */
  imported: number;

  /**
   * Number of stories that failed
   */
  failed: number;
}

/**
 * Import result summary
 */
export interface ImportResult {
  /**
   * Whether the import completed without errors
   */
  success: boolean;

  /**
   * Number of stories successfully imported
   */
  imported: number;

  /**
   * Total number of stories attempted
   */
  total: number;

  /**
   * Error messages (if any)
   */
  errors?: string[];
}

/**
 * Workflow ID to directory name mapping
 */
const WORKFLOW_TO_DIR: Record<string, string> = {
  WORKFLOW_COMPLET: 'workflow-complet',
  DOCUMENT_PROJECT: 'document-project',
  QUICK_FLOW: 'quick-flow',
  COMPLEX_FEATURE: 'workflow-complet', // Maps to same as WORKFLOW_COMPLET
  DEBUG: 'debug',
};

/**
 * Import BMAD workflow stories into a project
 *
 * @param projectId - Target project ID
 * @param workflowId - Workflow type (e.g., "QUICK_FLOW")
 * @param onProgress - Optional progress callback
 * @returns Import result summary
 */
export async function importWorkflowStories(
  projectId: string,
  workflowId: string,
  onProgress?: (progress: ImportProgress) => void,
): Promise<ImportResult> {
  const errors: string[] = [];
  let imported = 0;
  let failed = 0;

  try {
    // Map workflow ID to directory name
    const workflowDir = WORKFLOW_TO_DIR[workflowId];
    if (!workflowDir) {
      throw new Error(`Unknown workflow type: ${workflowId}`);
    }

    // Discover story files
    const storyFiles = await discoverStoryFiles(workflowDir);
    const total = storyFiles.length;

    if (total === 0) {
      return {
        success: true,
        imported: 0,
        total: 0,
      };
    }

    // Process stories in reverse order (highest number first)
    // This ensures [1] is created last and appears first in "most recent" view
    const reversedFiles = [...storyFiles].reverse();
    let sequenceNumber = total;

    for (let i = 0; i < reversedFiles.length; i++) {
      const storyFile = reversedFiles[i];

      try {
        // Fetch story content
        const markdown = await fetchStoryFile(workflowDir, storyFile.filename);

        // Parse story
        const parsedStory = parseStoryMarkdown(markdown, sequenceNumber);

        // Notify progress
        if (onProgress) {
          onProgress({
            total,
            current: i + 1,
            currentStory: parsedStory.title,
            imported,
            failed,
          });
        }

        // Create task via API
        await createTaskFromStory(projectId, parsedStory);

        imported++;
        sequenceNumber--;
      } catch (error) {
        failed++;
        const errorMsg = `Failed to import ${storyFile.filename}: ${
          error instanceof Error ? error.message : 'Unknown error'
        }`;
        errors.push(errorMsg);
        console.error(errorMsg, error);

        // Continue with other stories even if one fails
      }
    }

    return {
      success: failed === 0,
      imported,
      total,
      errors: errors.length > 0 ? errors : undefined,
    };
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error during import';
    errors.push(errorMsg);
    console.error('Import failed:', error);

    return {
      success: false,
      imported,
      total: 0,
      errors,
    };
  }
}

/**
 * Create a Vibe Kanban task from a parsed story
 *
 * @param projectId - Target project ID
 * @param story - Parsed story data
 * @returns Created task
 */
async function createTaskFromStory(projectId: string, story: ParsedStory) {
  // Format task title with sequence number
  const title = `[${story.sequenceNumber}] ${story.title}`;

  // Create task payload
  const taskData: CreateTask = {
    project_id: projectId,
    title,
    description: story.description,
    status: 'todo',
    parent_workspace_id: null,
    image_ids: null,
  };

  // Create task via existing API
  return tasksApi.create(taskData);
}
