import { cn } from '@/lib/utils';

interface MdIconProps {
  className?: string;
}

/**
 * MdIcon - A simple "MD" text badge icon for the ContextBar.
 * Styled to match the existing IDE icon pattern.
 */
export function MdIcon({ className = 'h-4 w-4' }: MdIconProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center justify-center font-bold text-[9px] leading-none',
        className
      )}
    >
      MD
    </span>
  );
}
