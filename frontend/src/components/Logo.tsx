/**
 * Logo component - Displays BMAD-VIBE-KANBAN branding
 */
export function Logo() {
  return (
    <div className="flex items-center gap-1 font-bold text-sm tracking-tight">
      <span className="text-orange-500">BMAD</span>
      <span className="text-muted-foreground">-</span>
      <span className="text-foreground">VIBE-KANBAN</span>
    </div>
  );
}
