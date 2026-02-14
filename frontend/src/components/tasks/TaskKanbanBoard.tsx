import { memo, useCallback } from 'react';
import {
  type DragEndEvent,
  KanbanBoard,
  KanbanCards,
  KanbanHeader,
  KanbanProvider,
} from '@/components/ui/shadcn-io/kanban';
import { TaskCard } from './TaskCard';
import type { TaskStatus, TaskWithAttemptStatus } from 'shared/types';
import { statusBoardColors, statusLabels } from '@/utils/statusLabels';
import { BmadWorkflowDialog } from '@/components/dialogs/tasks/BmadWorkflowDialog';

export type KanbanColumns = Record<TaskStatus, TaskWithAttemptStatus[]>;

interface TaskKanbanBoardProps {
  columns: KanbanColumns;
  onDragEnd: (event: DragEndEvent) => void;
  onViewTaskDetails: (task: TaskWithAttemptStatus) => void;
  selectedTaskId?: string;
  onCreateTask?: () => void;
  projectId: string;
}

function TaskKanbanBoard({
  columns,
  onDragEnd,
  onViewTaskDetails,
  selectedTaskId,
  onCreateTask,
  projectId,
}: TaskKanbanBoardProps) {
  /**
   * handleBmadClick - Opens BMAD Workflow dialog for the todo column
   */
  const handleBmadClick = useCallback(async () => {
    const todoTasks = columns.todo || [];
    const result = await BmadWorkflowDialog.show({
      projectId,
      todoTasks,
    });

    if (result.action === 'workflow' && result.workflowId) {
      // Display workflow info - actual import requires shell execution
      // The user will run the import script manually with the selected workflow
      const workflowLabels: Record<string, string> = {
        WORKFLOW_COMPLET: 'NEW PROJECT',
        DOCUMENT_PROJECT: 'DOCUMENT PROJECT',
        QUICK_FLOW: 'SIMPLE FEATURE',
        COMPLEX_FEATURE: 'COMPLEX FEATURE',
        DEBUG: 'BUG FIX',
      };
      const label = workflowLabels[result.workflowId] || result.workflowId;
      // Log selected workflow for user reference
      console.info(`[BMAD] Selected workflow: ${label} (${result.workflowId})`);
    }
  }, [columns.todo, projectId]);

  return (
    <KanbanProvider onDragEnd={onDragEnd}>
      {Object.entries(columns).map(([status, tasks]) => {
        const statusKey = status as TaskStatus;
        const isTodoColumn = statusKey === 'todo';
        return (
          <KanbanBoard key={status} id={statusKey}>
            <KanbanHeader
              name={statusLabels[statusKey]}
              color={statusBoardColors[statusKey]}
              onAddTask={onCreateTask}
              showBmadButton={isTodoColumn}
              onBmadClick={isTodoColumn ? handleBmadClick : undefined}
            />
            <KanbanCards>
              {tasks.map((task, index) => (
                <TaskCard
                  key={task.id}
                  task={task}
                  index={index}
                  status={statusKey}
                  onViewDetails={onViewTaskDetails}
                  isOpen={selectedTaskId === task.id}
                  projectId={projectId}
                />
              ))}
            </KanbanCards>
          </KanbanBoard>
        );
      })}
    </KanbanProvider>
  );
}

export default memo(TaskKanbanBoard);
