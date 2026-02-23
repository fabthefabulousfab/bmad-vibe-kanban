---
project_name: 'bmad-vibe-kanban'
user_name: 'Fabulousfab'
date: '2026-02-23'
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'testing_rules', 'code_quality', 'workflow_rules', 'critical_rules']
existing_patterns_found: 62
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

### Backend (Rust)
- **Rust**: nightly-2025-12-04 (REQUIRED - async traits, advanced features)
- **Axum**: 0.8.4 (with macros, multipart, WebSocket features)
- **Tokio**: 1.0 (full features)
- **sqlx**: compile-time query checking (offline mode with .sqlx cache)
- **git2**: 0.20.3 (libgit2 bindings - NO CLI fallback)
- **serde**: 1.0 with preserve_order for JSON
- **ts-rs**: git branch xazukx/use-ts-enum (TypeScript type generation)
- **thiserror**: 2.0.12 (error handling)
- **tracing**: 0.1.43 (structured logging)

### Frontend (React + TypeScript)
- **React**: 18.2.0 with React Compiler (babel-plugin-react-compiler)
- **TypeScript**: 5.9.2 (strict mode enabled)
- **Vite**: 5.0.8
- **TailwindCSS**: 3.4.0
- **Zustand**: 4.5.4 (5 global stores only)
- **Lexical**: 0.36.2 (rich text editor)
- **xterm.js**: 5.5.0 (terminal emulation)
- **ElectricSQL**: @tanstack/electric-db-collection 0.2.6
- **rfc6902**: 5.1.2 (JSON Patch application)
- **NiceModal**: @ebay/nice-modal-react 1.2.13 (type-safe dialog system)
- **Phosphor Icons**: @phosphor-icons/react 2.1.10 (ui-new ONLY)

### Build & Dev
- **Node.js**: >= 18
- **pnpm**: 10.13.1 (workspace manager)
- **Vitest**: 4.0.18 (frontend testing)
- **ESLint**: 8.55.0 (19 custom rules)
- **Prettier**: 3.6.1

---

## Critical Implementation Rules

### Rust-Specific Rules

#### Crate Dependency Hierarchy (STRICT)
```
server (entry point)
  -> deployment (abstract trait)
  -> local-deployment (SQLite implementation)
  -> services (business logic)
  -> db (models + migrations)
  -> git (libgit2 operations)
  -> executors (AI agent implementations)
  -> utils (shared types, MsgStore)
```
- NEVER import upward in hierarchy (e.g., services cannot import server)
- NEVER add circular dependencies between crates

#### Deployment Trait Pattern
- All services accessed via `Deployment` trait, not direct construction
- Adding new service requires: trait method + LocalDeployment implementation
- Route handlers generic over `D: Deployment` for future RemoteDeployment

#### Type Generation (ts-rs)
- ALL new model structs MUST have `#[derive(TS)]` annotation
- Run `cargo run --bin generate_types` after model changes
- Types output to `shared/types.ts` - frontend imports from there
- NEVER duplicate type definitions in frontend

#### Git Operations
- USE `GitService` via libgit2 (crates/git/)
- NEVER shell out to git CLI
- Worktree paths: `{worktree_base}/{workspace_id}/{repo_name}`
- Always handle orphaned worktrees (72-hour cleanup, 1-hour if archived)

#### Database Migrations
- Migrations are SEQUENTIAL (69 migrations exist)
- NEVER modify existing migration files
- New migrations: `sqlx migrate add -r <description>`
- IDs stored as BLOB in SQLite, serialized as UUID strings in JSON
- Enums stored as TEXT with CHECK constraints

#### Naming Conventions (Rust)
- Structs: `PascalCase` (`WorkspaceRepo`, `CodingAgentTurn`)
- Functions: `snake_case` (`find_all`, `create_workspace`)
- Modules: `snake_case` (`container_service`)
- Crate names: `kebab-case` in Cargo.toml

---

### Frontend-Specific Rules

#### Container/View Pattern (ENFORCED BY ESLINT)
```
containers/     -> Fetch data, manage state, handle mutations
views/          -> STATELESS - receive all data via props
primitives/     -> STATELESS - base UI elements
hooks/          -> Logic only, NO JSX allowed
dialogs/        -> Dialog wrappers using NiceModal
```

**Views and Primitives CANNOT use:**
- `useState`, `useReducer`, `useContext`
- `useQuery`, `useMutation`, `useInfiniteQuery`
- `useEffect`, `useLayoutEffect`, `useCallback`
- `useNavigate`
- Direct API imports (`@/lib/api`)

**Containers CANNOT have optional props** - make required or provide defaults

#### Dialog System (Type-Safe NiceModal)
```typescript
// CORRECT:
DialogName.show({ prop1: value })
DialogName.hide()

// FORBIDDEN (ESLint errors):
NiceModal.show(DialogName, props)
showModal(DialogName, props)
NiceModal.register()
```

#### Icon System (ui-new ONLY)
- USE: `@phosphor-icons/react`
- FORBIDDEN: `lucide-react` in ui-new components
- Icon sizes MUST use design system classes:
  - `size-icon-xs`, `size-icon-sm`, `size-icon-base`, `size-icon-lg`, `size-icon-xl`
- FORBIDDEN: `size={16}` prop, `size-[10px]`, generic `size-3`

#### File Naming (ENFORCED BY ESLINT)
- React components (.tsx): `PascalCase` (e.g., `TaskDetails.tsx`)
- Hooks: `camelCase` starting with `use` (e.g., `useTask.ts`)
- Utils/lib/config: `camelCase` (e.g., `formatDate.ts`)
- shadcn components (src/components/ui/): `kebab-case` (exception)

#### State Management
- 5 Zustand stores exist - DO NOT create new stores
- Use React Context for scoped state (25 providers exist)
- State updates: immutable with spread operator
- SSE patches applied via `rfc6902.applyPatch()`

#### Barrel Exports
- FORBIDDEN in ui-new: no `export * from` or re-exports in index.ts
- Export directly from source files

---

### Testing Rules

#### Backend Testing
- `cargo test` in each crate
- Tests alongside code in `src/` or in `tests/` directory
- sqlx offline mode requires `.sqlx/` cache files

#### Frontend Testing
- Vitest for unit/integration tests
- Test files: `__tests__/` directories co-located with services
- Shared test utilities: `frontend/src/test/`
- i18n literals allowed in test files

#### Test Coverage Expectations
- 80% minimum coverage target (per CLAUDE.md)
- Unit tests for utilities
- Integration tests for APIs
- E2E tests for critical flows

---

### Code Quality & Style Rules

#### TypeScript Configuration
- Strict mode enabled (`strict: true`)
- `noUnusedLocals: true` - no unused variables
- `noUnusedParameters: true` - no unused params
- `noFallthroughCasesInSwitch: true` - exhaustive switch
- `@typescript-eslint/switch-exhaustiveness-check: error`

#### Import Path Aliases
```typescript
@/*           -> ./src/*
@dialogs/*    -> ./src/components/dialogs/*
shared/*      -> ../shared/*
```

#### ESLint Rules (Key Custom Rules)
- `unused-imports/no-unused-imports: error`
- `@typescript-eslint/no-explicit-any: warn`
- `eslint-comments/no-use: error` (no eslint-disable comments)
- `deprecation/deprecation: error` (in ui-new)

#### Formatting
- Prettier handles all formatting
- No manual formatting needed
- Run `pnpm lint` before committing

---

### Development Workflow Rules

#### Git Workflow
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- All tests must pass before merge
- Merge locally to main and push (no PRs for internal work)
- Workflow: `git checkout main && git merge <branch> && git push origin main`

#### Build Commands
- `pnpm build` - Build frontend
- `cargo build` - Build backend
- `./build-vibe-kanban.sh` - Full build script
- `./local-build.sh` - Local development build
- `./quick-check.sh` - Quick lint/format check

#### Type Generation After Model Changes
1. Modify Rust model with `#[derive(TS)]`
2. Run `cargo run --bin generate_types`
3. Verify `shared/types.ts` updated
4. Frontend imports from `shared/types.ts`

---

### Critical Don't-Miss Rules

#### Anti-Patterns to AVOID
- Putting business logic in route handlers (use services layer)
- Creating new Zustand stores (use existing 5 or Context)
- Shelling out to git CLI (use GitService)
- Hardcoding config values (use Config service or env vars)
- Mutating state directly (always immutable updates)
- Using `console.log` in production code
- Swallowing errors silently in global handlers
- Optional props in container components
- JSX in ui-new/hooks/ directory
- Re-exports in ui-new index files

#### Security Rules
- No hardcoded secrets
- Environment variables for sensitive data
- Validate all user inputs (Zod or similar)
- Origin validation middleware for local API
- JWT + OAuth for remote API
- Parameterized queries only (sqlx compile-time checking)

#### Performance Rules
- SQLite DELETE journal mode (cross-platform compatibility)
- MsgStore: 10K broadcast channel capacity, 100MB FIFO buffer
- Avoid blocking operations in async handlers
- Use SSE for real-time updates (not polling)

#### Edge Cases to Handle
- Orphaned git worktrees (cleanup after 72 hours)
- ElectricSQL reconnection after network loss
- Concurrent worktree operations on same repo
- Large repository worktree creation (sub-2s target for <1GB)

---

## New Feature Implementation Sequence

When adding new features, follow this exact order:

1. **Define data model** - SQLite migration + model struct with `#[derive(TS)]`
2. **Add service logic** - `crates/services/src/services/`
3. **Register in Deployment trait** - if service needs trait exposure
4. **Implement in LocalDeployment** - `crates/local-deployment/`
5. **Add route handlers** - thin wrappers in `crates/server/src/routes/`
6. **Register SQLite hooks** - if real-time events needed
7. **Generate TypeScript types** - `cargo run --bin generate_types`
8. **Build frontend Container** - data fetching, state management
9. **Build frontend View** - stateless display component
10. **Add API client** - `frontend/src/services/`
11. **Connect state** - Zustand store or React Context

---

## Quick Reference

| Task | Location |
|------|----------|
| Add SQLite table | `crates/db/migrations/` + `crates/db/src/models/` |
| Add API endpoint | `crates/server/src/routes/` |
| Add business logic | `crates/services/src/services/` |
| Add AI agent | `crates/executors/src/executors/` |
| Add React component | `frontend/src/components/ui-new/` |
| Add API client | `frontend/src/services/` |
| Add global state | Modify existing Zustand store |
| Add scoped state | New React Context provider |
| Add dialog | `frontend/src/components/dialogs/` with NiceModal |
