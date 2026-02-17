# Vibe Kanban - Component Inventory

> React component catalog and organization

## Component Structure Overview

| Category | Location | Count | Purpose |
|----------|----------|-------|---------|
| **Root Components** | `frontend/src/components/` | 12 files | Top-level shared components |
| **Feature Components** | `frontend/src/components/*/` | 17 directories | Feature-specific components |
| **UI Primitives** | `frontend/src/components/ui/` | 27+ files | Reusable UI building blocks |
| **New Design System** | `frontend/src/components/ui-new/` | 9 files | Updated design components |

## Root Components

| Component | File | Purpose |
|-----------|------|---------|
| `AgentAvailabilityIndicator` | `AgentAvailabilityIndicator.tsx` | Shows agent online/offline status |
| `ConfigProvider` | `ConfigProvider.tsx` | Application configuration context |
| `DevBanner` | `DevBanner.tsx` | Development mode indicator |
| `DiffCard` | `DiffCard.tsx` | Git diff display card |
| `DiffViewSwitch` | `DiffViewSwitch.tsx` | Toggle between diff view modes |
| `EditorAvailabilityIndicator` | `EditorAvailabilityIndicator.tsx` | Editor connection status |
| `ExecutorConfigForm` | `ExecutorConfigForm.tsx` | Agent configuration form |
| `Logo` | `Logo.tsx` | Vibe Kanban logo component |
| `SearchBar` | `SearchBar.tsx` | Global search input |
| `TagManager` | `TagManager.tsx` | Task tag management UI |
| `ThemeProvider` | `ThemeProvider.tsx` | Dark/light theme context |

## Feature Component Directories

### Dialogs (`dialogs/`)

Modal dialog components:

| Component | Purpose |
|-----------|---------|
| `CreateProjectDialog` | New project creation |
| `CreateTaskDialog` | New task creation |
| `SettingsDialog` | Application settings |
| `ConfirmDialog` | Confirmation prompts |
| (11 dialog files total) | |

### Tasks (`tasks/`)

Task management components:

| Component | Purpose |
|-----------|---------|
| `TaskCard` | Kanban task card |
| `TaskDetail` | Task detail view |
| `TaskEditor` | Task editing form |
| `TaskList` | Task list view |
| `SubtaskList` | Subtask management |
| (17 files total) | |

### Panels (`panels/`)

Main application panels:

| Component | Purpose |
|-----------|---------|
| `DiffPanel` | Code diff viewer |
| `ConversationPanel` | Agent conversation |
| `TerminalPanel` | Process output |
| `FilesPanel` | File changes list |
| (6 files total) | |

### Layout (`layout/`)

Application layout components:

| Component | Purpose |
|-----------|---------|
| `Sidebar` | Main navigation |
| `Header` | Top bar |
| `MainContent` | Content area |
| `ResizablePanels` | Panel layout |

### Projects (`projects/`)

Project management components:

| Component | Purpose |
|-----------|---------|
| `ProjectList` | Project listing |
| `ProjectCard` | Project display |
| `ProjectSettings` | Project config |

### Agents (`agents/`)

Agent-related components:

| Component | Purpose |
|-----------|---------|
| `AgentSelector` | Choose AI agent |
| `AgentStatus` | Agent state display |

### Conversation (`NormalizedConversation/`)

Chat/conversation UI:

| Component | Purpose |
|-----------|---------|
| `ConversationView` | Message display |
| `MessageBubble` | Individual message |
| `TurnList` | Conversation turns |
| (8 files total) | |

### Settings (`settings/`)

Settings UI components:

| Component | Purpose |
|-----------|---------|
| `GeneralSettings` | General options |
| `ExecutorSettings` | Agent config |

### Diff (`diff/`)

Code diff components:

| Component | Purpose |
|-----------|---------|
| `DiffViewer` | Full diff display |
| `FileDiff` | Single file diff |

### IDE Integration (`ide/`)

Editor integration:

| Component | Purpose |
|-----------|---------|
| `IDEButton` | Open in editor |
| `RemoteSSH` | SSH connection |

### Organization (`org/`)

Organization features:

| Component | Purpose |
|-----------|---------|
| `OrgSelector` | Org picker |
| `OrgSettings` | Org config |

### RJSF (`rjsf/`)

JSON Schema Form components:

| Component | Purpose |
|-----------|---------|
| Custom widgets for agent config forms |
| (5 files) | |

### Logs (`logs/`)

Logging components:

| Component | Purpose |
|-----------|---------|
| `LogViewer` | Process log display |

### Showcase (`showcase/`)

Demo/example components:

| Component | Purpose |
|-----------|---------|
| Component examples | |

### Legacy Design (`legacy-design/`)

Deprecated components:

| Component | Purpose |
|-----------|---------|
| Old design system components | |

## UI Primitives (`ui/`)

Reusable UI components based on Radix UI:

| Component | Based On | Purpose |
|-----------|----------|---------|
| `Button` | Native | Action buttons |
| `Dialog` | Radix Dialog | Modal dialogs |
| `DropdownMenu` | Radix Dropdown | Dropdown menus |
| `Popover` | Radix Popover | Popup content |
| `Select` | Radix Select | Select inputs |
| `Tooltip` | Radix Tooltip | Hover tips |
| `Switch` | Radix Switch | Toggle switches |
| `Label` | Radix Label | Form labels |
| `Separator` | Radix Separator | Visual dividers |
| `Card` | Custom | Card containers |
| `Input` | Native | Text inputs |
| `Textarea` | Native | Multiline input |
| `Badge` | Custom | Status badges |
| `Skeleton` | Custom | Loading states |
| `Carousel` | Embla | Image carousel |
| `Command` | cmdk | Command palette |
| (27+ files total) | | |

## New Design System (`ui-new/`)

Updated design components (PascalCase naming):

| Component | Purpose |
|-----------|---------|
| `Field.tsx` | Form field wrapper |
| `Label.tsx` | Form labels |
| `Input.tsx` | Text inputs |
| `Button.tsx` | Action buttons |
| (9 files total) | |

**Styling Guidelines:** See `frontend/CLAUDE.md` for new design system:
- CSS variables in `src/styles/new/index.css`
- Scoped to `.new-design` class
- Custom color tokens: `text-high`, `text-normal`, `text-low`
- Custom spacing: `p-half`, `p-base`, `p-double`

## Hooks Directory

The project has 85+ custom hooks in `frontend/src/hooks/`:

| Category | Examples |
|----------|----------|
| **Data Fetching** | `useProjects`, `useTasks`, `useWorkspaces` |
| **State** | `useSelectedProject`, `useSelectedTask` |
| **WebSocket** | `useWebSocket`, `useProcessLogs` |
| **Git** | `useDiff`, `useBranches`, `useGitStatus` |
| **UI** | `useKeyboardShortcuts`, `useResizable` |

## Context Providers

20 context providers in `frontend/src/contexts/`:

| Context | Purpose |
|---------|---------|
| `ConfigContext` | App configuration |
| `WebSocketContext` | Real-time connection |
| `ThemeContext` | Theme state |
| `KeyboardContext` | Shortcut handling |
| `SettingsContext` | User preferences |

## Component Patterns

### Container/View Pattern

```
containers/          # State management
  TaskContainer.tsx  # Fetches data, handles actions

views/               # Stateless display
  TaskView.tsx       # Receives props, renders UI
```

### State Management

- **Zustand stores** for global UI state (`stores/`)
- **TanStack Query** for server state (via hooks)
- **React Context** for cross-cutting concerns

### Styling Approach

- **TailwindCSS** for utility classes
- **Two config files**: `tailwind.legacy.config.js` and `tailwind.new.config.js`
- **Radix UI** for accessible primitives
- **Framer Motion** for animations

---

*Generated by BMAD Document Project Workflow v1.2.0*
