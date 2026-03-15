import { cn } from '@/lib/utils';
import { SpinnerGap } from '@phosphor-icons/react';

export type GitAction = 'commit-push' | 'merge-review' | 'merge-stable';

interface GitActionBarViewProps {
  selectedAction: GitAction;
  onSelectAction: (action: GitAction) => void;
  onExecute: () => void;
  isExecuting: boolean;
}

const ACTION_LABELS: Record<GitAction, string> = {
  'commit-push': 'Commit & Push',
  'merge-review': 'Merge to Review',
  'merge-stable': 'Merge to Stable',
};

/**
 * GitActionBarView - Stateless dropdown + "DO!" button for git actions.
 * Shows spinner when executing, disables button during execution.
 */
export function GitActionBarView({
  selectedAction,
  onSelectAction,
  onExecute,
  isExecuting,
}: GitActionBarViewProps) {
  return (
    <div className="flex flex-col gap-half px-base py-base border-t border-secondary">
      <select
        className={cn(
          'w-full h-8 px-2 text-sm rounded border border-secondary',
          'bg-secondary/30 text-normal',
          'focus:outline-none focus:ring-1 focus:ring-accent'
        )}
        value={selectedAction}
        onChange={(e) => onSelectAction(e.target.value as GitAction)}
        disabled={isExecuting}
        aria-label="Select git action"
      >
        {(Object.entries(ACTION_LABELS) as [GitAction, string][]).map(
          ([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          )
        )}
      </select>
      <button
        className={cn(
          'w-full h-8 text-sm font-bold rounded transition-colors',
          'bg-accent text-white hover:bg-accent/90',
          'disabled:opacity-50 disabled:cursor-not-allowed',
          'flex items-center justify-center gap-1'
        )}
        onClick={onExecute}
        disabled={isExecuting}
        aria-label="Execute git action"
      >
        {isExecuting ? (
          <>
            <SpinnerGap className="size-icon-sm animate-spin" />
            Running...
          </>
        ) : (
          'DO!'
        )}
      </button>
    </div>
  );
}
