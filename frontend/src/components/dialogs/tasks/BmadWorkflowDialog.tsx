/**
 * BmadWorkflowDialog - Dialog for BMAD workflow selection and bulk task operations
 *
 * This dialog provides:
 * - Workflow selection (NEW PROJECT, DOCUMENT PROJECT, SIMPLE FEATURE, etc.)
 * - Direct import of workflow stories into the project
 * - Option to delete all tasks in the "To Do" column
 */
import { useState } from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Alert } from '@/components/ui/alert';
import { Label } from '@/components/ui/label';
import { Progress } from '@/components/ui/progress';
import { tasksApi } from '@/lib/api';
import type { TaskWithAttemptStatus } from 'shared/types';
import NiceModal, { useModal } from '@ebay/nice-modal-react';
import { defineModal } from '@/lib/modals';
import {
  AlertTriangle,
  Trash2,
  Check,
  CheckCircle,
  Loader2,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import {
  importWorkflowStories,
  type ImportProgress,
  type WorkflowId,
} from '@/services/storyImportService';

/**
 * BMAD Workflow definitions matching import-bmad-workflow.sh
 */
const BMAD_WORKFLOWS = [
  {
    id: 'WORKFLOW_COMPLET',
    label: 'NEW PROJECT',
    description: 'Complete workflow for new project setup',
    menuChoice: '1',
  },
  {
    id: 'DOCUMENT_PROJECT',
    label: 'DOCUMENT PROJECT',
    description: 'Documentation workflow for existing project',
    menuChoice: '2',
  },
  {
    id: 'QUICK_FLOW',
    label: 'SIMPLE FEATURE',
    description: 'Quick workflow for simple features',
    menuChoice: '3',
  },
  {
    id: 'COMPLEX_FEATURE',
    label: 'COMPLEX FEATURE',
    description: 'Extended workflow for complex features',
    menuChoice: '4',
  },
  {
    id: 'DEBUG',
    label: 'BUG FIX',
    description: 'Debug and fix workflow',
    menuChoice: '5',
  },
] as const;

export interface BmadWorkflowDialogProps {
  projectId: string;
  todoTasks: TaskWithAttemptStatus[];
  onRefresh?: () => void;
}

export type BmadWorkflowResult = {
  action: 'workflow' | 'delete_all' | 'canceled';
  workflowId?: string;
  imported?: number;
};

const BmadWorkflowDialogImpl = NiceModal.create<BmadWorkflowDialogProps>(
  ({ projectId, todoTasks, onRefresh }) => {
    const modal = useModal();
    const [selectedWorkflow, setSelectedWorkflow] = useState<WorkflowId>(
      BMAD_WORKFLOWS[0].id
    );
    const [isImporting, setIsImporting] = useState(false);
    const [importProgress, setImportProgress] = useState<ImportProgress | null>(null);
    const [isDeleting, setIsDeleting] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
    const [importSuccess, setImportSuccess] = useState<{
      imported: number;
      skipped: number;
    } | null>(null);


    /**
     * handleExecuteWorkflow - Imports workflow stories directly
     */
    const handleExecuteWorkflow = async () => {
      setIsImporting(true);
      setError(null);
      setImportSuccess(null);

      try {
        const result = await importWorkflowStories(
          projectId,
          selectedWorkflow,
          (progress) => {
            setImportProgress(progress);
          }
        );

        if (!result.success && result.errors) {
          setError(result.errors.join('\n'));
          setIsImporting(false);
          return;
        }

        setImportSuccess({
          imported: result.imported,
          skipped: result.skipped,
        });

        // Refresh the task list
        if (onRefresh) {
          onRefresh();
        }

        // Close dialog after brief success display
        setTimeout(() => {
          const workflowResult: BmadWorkflowResult = {
            action: 'workflow',
            workflowId: selectedWorkflow,
            imported: result.imported,
          };
          modal.resolve(workflowResult);
          modal.hide();
        }, 2500); // Increased from 1500ms to allow reading skipped message
      } catch (err: unknown) {
        const errorMessage =
          err instanceof Error ? err.message : 'Failed to import stories';
        setError(errorMessage);
        setIsImporting(false);
      }
    };

    /**
     * handleDeleteAllTodoTasks - Deletes all tasks in To Do column
     */
    const handleDeleteAllTodoTasks = async () => {
      setIsDeleting(true);
      setError(null);

      try {
        // Delete each task in the todo list
        for (const task of todoTasks) {
          await tasksApi.delete(task.id);
        }

        if (onRefresh) {
          onRefresh();
        }

        const result: BmadWorkflowResult = {
          action: 'delete_all',
        };
        modal.resolve(result);
        modal.hide();
      } catch (err: unknown) {
        const errorMessage =
          err instanceof Error ? err.message : 'Failed to delete tasks';
        setError(errorMessage);
      } finally {
        setIsDeleting(false);
        setShowDeleteConfirm(false);
      }
    };

    /**
     * handleCancel - Closes dialog without action
     */
    const handleCancel = () => {
      const result: BmadWorkflowResult = {
        action: 'canceled',
      };
      modal.resolve(result);
      modal.hide();
    };

    const isProcessing = isImporting || isDeleting;

    return (
      <Dialog open={modal.visible} onOpenChange={(open) => !open && handleCancel()}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>BMAD Workflow</DialogTitle>
            <DialogDescription>
              {isImporting
                ? 'Importing workflow stories...'
                : 'Select a workflow to import stories or manage existing tasks.'}
            </DialogDescription>
          </DialogHeader>

          <div className="py-4 space-y-6">
            {/* Workflow Selection */}
            <div className="space-y-3">
              <Label className="text-sm font-medium">Select Workflow</Label>
              <div className="space-y-2">
                {BMAD_WORKFLOWS.map((workflow) => {
                  const isSelected = selectedWorkflow === workflow.id;
                  return (
                    <div
                      key={workflow.id}
                      className={cn(
                        'flex items-start space-x-3 p-3 rounded-md border cursor-pointer transition-colors',
                        isSelected
                          ? 'border-orange-500 bg-orange-500/10'
                          : 'hover:bg-accent',
                        isProcessing && 'opacity-50 pointer-events-none'
                      )}
                      onClick={() => !isProcessing && setSelectedWorkflow(workflow.id)}
                    >
                      <div
                        className={cn(
                          'mt-0.5 h-4 w-4 rounded-full border-2 flex items-center justify-center',
                          isSelected
                            ? 'border-orange-500 bg-orange-500'
                            : 'border-muted-foreground'
                        )}
                      >
                        {isSelected && <Check className="h-3 w-3 text-white" />}
                      </div>
                      <div className="flex-1">
                        <p className="font-medium text-sm">{workflow.label}</p>
                        <p className="text-sm text-muted-foreground">
                          {workflow.description}
                        </p>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Import Progress */}
            {isImporting && importProgress && (
              <div className="space-y-3">
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">
                      Importing story {importProgress.current} of {importProgress.total}
                    </span>
                    <span className="font-medium">
                      {Math.round((importProgress.current / importProgress.total) * 100)}%
                    </span>
                  </div>
                  <Progress
                    value={(importProgress.current / importProgress.total) * 100}
                    className="h-2"
                  />
                  <p className="text-sm text-muted-foreground truncate">
                    {importProgress.currentStory}
                  </p>
                </div>
              </div>
            )}

            {/* Success Message */}
            {importSuccess !== null && (
              <Alert className="border-green-500 bg-green-500/10">
                <CheckCircle className="h-4 w-4 text-green-500" />
                <div className="ml-2 text-sm">
                  Successfully imported {importSuccess.imported} stories!
                  {importSuccess.skipped > 0 && (
                    <span className="block text-muted-foreground mt-1">
                      ({importSuccess.skipped} duplicates skipped)
                    </span>
                  )}
                </div>
              </Alert>
            )}

            {/* Separator */}
            <div className="border-t" />

            {/* Delete All Section */}
            <div className="space-y-3">
              <Label className="text-sm font-medium">Task Management</Label>

              {!showDeleteConfirm ? (
                <Button
                  variant="destructive"
                  className="w-full"
                  onClick={() => setShowDeleteConfirm(true)}
                  disabled={todoTasks.length === 0 || isProcessing}
                >
                  <Trash2 className="mr-2 h-4 w-4" />
                  Delete All To Do Tasks ({todoTasks.length})
                </Button>
              ) : (
                <div className="space-y-3">
                  <Alert variant="destructive">
                    <AlertTriangle className="h-4 w-4" />
                    <div className="ml-2">
                      <strong>Warning:</strong> This will permanently delete{' '}
                      {todoTasks.length} task(s). This action cannot be undone.
                    </div>
                  </Alert>
                  <div className="flex gap-2">
                    <Button
                      variant="outline"
                      className="flex-1"
                      onClick={() => setShowDeleteConfirm(false)}
                      disabled={isDeleting}
                    >
                      Cancel
                    </Button>
                    <Button
                      variant="destructive"
                      className="flex-1"
                      onClick={handleDeleteAllTodoTasks}
                      disabled={isDeleting}
                    >
                      {isDeleting ? 'Deleting...' : 'Confirm Delete'}
                    </Button>
                  </div>
                </div>
              )}
            </div>

            {/* Error Display */}
            {error && (
              <Alert variant="destructive">
                <AlertTriangle className="h-4 w-4" />
                <div className="ml-2 text-sm whitespace-pre-wrap">
                  {error}
                </div>
              </Alert>
            )}
          </div>

          <DialogFooter className="gap-2">
            <Button
              variant="outline"
              onClick={handleCancel}
              disabled={isProcessing}
            >
              Cancel
            </Button>
            <Button
              onClick={handleExecuteWorkflow}
              disabled={isProcessing || importSuccess !== null}
            >
              {isImporting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Importing...
                </>
              ) : (
                'Execute'
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    );
  }
);

export const BmadWorkflowDialog = defineModal<
  BmadWorkflowDialogProps,
  BmadWorkflowResult
>(BmadWorkflowDialogImpl);
