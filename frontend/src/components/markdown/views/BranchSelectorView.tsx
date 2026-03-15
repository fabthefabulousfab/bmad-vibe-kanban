import type { GitBranch } from 'shared/types';
import { cn } from '@/lib/utils';

interface BranchSelectorViewProps {
  branches: GitBranch[];
  currentBranch: string;
  onSelectBranch: (branchName: string) => void;
  isLoading: boolean;
}

/**
 * BranchSelectorView - Stateless dropdown for selecting git branches.
 * Shows the current branch as selected, calls onSelectBranch on change.
 */
export function BranchSelectorView({
  branches,
  currentBranch,
  onSelectBranch,
  isLoading,
}: BranchSelectorViewProps) {
  return (
    <div className="px-base py-half">
      <select
        className={cn(
          'w-full h-8 px-2 text-sm rounded border border-secondary',
          'bg-secondary/30 text-normal',
          'focus:outline-none focus:ring-1 focus:ring-accent',
          isLoading && 'opacity-50 cursor-wait'
        )}
        value={currentBranch}
        onChange={(e) => onSelectBranch(e.target.value)}
        disabled={isLoading}
        aria-label="Select branch"
      >
        {branches.length === 0 && (
          <option value="">
            {isLoading ? 'Loading branches...' : 'No branches found'}
          </option>
        )}
        {branches.map((branch) => (
          <option key={branch.name} value={branch.name}>
            {branch.name}
            {branch.is_current ? ' (current)' : ''}
          </option>
        ))}
      </select>
    </div>
  );
}
