# Vibe Kanban - Development Guide

> Complete guide for setting up and developing the Vibe Kanban codebase

## Prerequisites

### Required Tools

| Tool | Version | Installation |
|------|---------|--------------|
| **Rust** | Latest stable | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh` |
| **Node.js** | >= 18 | [nodejs.org](https://nodejs.org) |
| **pnpm** | >= 8 | `npm install -g pnpm` |

### Additional Development Tools

```bash
# Cargo utilities
cargo install cargo-watch   # Hot reload for Rust
cargo install sqlx-cli      # Database migrations
```

## Initial Setup

### 1. Clone and Install

```bash
git clone https://github.com/BloopAI/vibe-kanban.git
cd vibe-kanban
pnpm install
```

### 2. Verify Installation

```bash
# Check Rust
cargo --version
rustc --version

# Check Node
node --version
pnpm --version
```

## Development Commands

### Primary Commands

| Command | Description |
|---------|-------------|
| `pnpm run dev` | Start full dev environment (frontend + backend) |
| `pnpm run dev:qa` | Start in QA mode (optimized for testing) |
| `pnpm run check` | Run frontend type checks |
| `pnpm run backend:check` | Run Rust cargo check |
| `pnpm run lint` | Lint both frontend and backend |

### Frontend Commands

| Command | Description |
|---------|-------------|
| `pnpm run frontend:dev` | Start frontend dev server only |
| `pnpm run frontend:check` | TypeScript type checking |
| `pnpm run frontend:lint` | ESLint + Prettier |

### Backend Commands

| Command | Description |
|---------|-------------|
| `pnpm run backend:dev:watch` | Start backend with hot reload |
| `pnpm run backend:check` | Cargo check |
| `pnpm run backend:lint` | Clippy linting |
| `cargo test --workspace` | Run all Rust tests |

### Type Generation

| Command | Description |
|---------|-------------|
| `pnpm run generate-types` | Generate TypeScript types from Rust |
| `pnpm run generate-types:check` | Verify types are up to date (CI) |

### Database Commands

| Command | Description |
|---------|-------------|
| `pnpm run prepare-db` | Prepare SQLx offline mode |
| `pnpm run prepare-db:check` | Verify SQLx is prepared (CI) |

## Development Workflow

### Starting Development

```bash
# Start everything
pnpm run dev

# This runs concurrently:
# - Frontend: http://localhost:${FRONTEND_PORT}
# - Backend:  http://localhost:${BACKEND_PORT}
# - Ports are auto-assigned to avoid conflicts
```

### Making Changes

#### Frontend Changes

1. Edit files in `frontend/src/`
2. Vite hot-reloads automatically
3. Run `pnpm run frontend:check` before committing

#### Backend Changes

1. Edit files in `crates/`
2. `cargo-watch` auto-rebuilds
3. Run `cargo test --workspace` for tests
4. Run `pnpm run backend:lint` before committing

#### Adding New Rust Types to Frontend

1. Add `#[derive(TS)]` to your Rust struct/enum
2. Run `pnpm run generate-types`
3. Import from `shared/types` in frontend

```rust
// In Rust
use ts_rs::TS;

#[derive(Debug, Serialize, Deserialize, TS)]
#[ts(export)]
pub struct MyNewType {
    pub id: Uuid,
    pub name: String,
}
```

```typescript
// In Frontend
import { MyNewType } from 'shared/types'
```

#### Database Migrations

```bash
# Create new migration
cd crates/db
sqlx migrate add my_migration_name

# Apply migrations (happens on startup)
# Or manually:
sqlx migrate run

# Update SQLx offline cache
pnpm run prepare-db
```

## Project Structure Conventions

### Rust Conventions

- **Module naming**: `snake_case`
- **Type naming**: `PascalCase`
- **Format**: `cargo fmt` (rustfmt.toml config)
- **Imports**: Group by crate (std, external, internal)

### TypeScript/React Conventions

- **Components**: `PascalCase` files and exports
- **Hooks**: `camelCase` with `use` prefix
- **Files**: `kebab-case` where practical
- **Formatting**: Prettier (2 spaces, single quotes, 80 cols)

### Styling Guidelines (Frontend)

The frontend uses a dual Tailwind config system:

- `tailwind.legacy.config.js` - Original styles
- `tailwind.new.config.js` - New design system (scoped to `.new-design`)

See `frontend/CLAUDE.md` for detailed styling guidelines.

## Environment Variables

### Development Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FRONTEND_PORT` | Auto-assigned | Frontend dev server port |
| `BACKEND_PORT` | Auto-assigned | Backend server port |
| `RUST_LOG` | `debug` | Rust logging level |
| `DISABLE_WORKTREE_ORPHAN_CLEANUP` | Not set | Debug worktrees |

### Build Variables

| Variable | Description |
|----------|-------------|
| `POSTHOG_API_KEY` | Analytics (optional) |
| `POSTHOG_API_ENDPOINT` | Analytics endpoint (optional) |

## Testing

### Rust Tests

```bash
# Run all tests
cargo test --workspace

# Run specific crate tests
cargo test -p server
cargo test -p executors

# Run with output
cargo test --workspace -- --nocapture
```

### Frontend Tests

```bash
cd frontend
pnpm run check   # Type checking
pnpm run lint    # Linting
```

## Building for Production

### Local Build (macOS)

```bash
# Build everything
./local-build.sh

# Test the build
cd npx-cli && node bin/cli.js
```

### npm Package

```bash
# Build and pack
pnpm run build:npx
cd npx-cli && pnpm pack
```

## Troubleshooting

### Common Issues

#### Port Conflicts

Ports are auto-assigned. If issues persist:

```bash
# Manually specify ports
FRONTEND_PORT=3000 BACKEND_PORT=3001 pnpm run dev
```

#### SQLx Compile Errors

```bash
# Regenerate SQLx cache
pnpm run prepare-db
```

#### TypeScript Type Errors

```bash
# Regenerate types from Rust
pnpm run generate-types
```

#### Rust Compilation Slow

```bash
# Use cargo check for faster feedback
cargo check --workspace
```

## Code Review Checklist

Before submitting PRs:

- [ ] `pnpm run check` passes
- [ ] `pnpm run lint` passes
- [ ] `cargo test --workspace` passes
- [ ] `pnpm run generate-types:check` passes (if Rust types changed)
- [ ] `pnpm run prepare-db:check` passes (if migrations changed)

## Contributing

1. Discuss changes in [GitHub Discussions](https://github.com/BloopAI/vibe-kanban/discussions) first
2. Fork and create feature branch
3. Follow code style guidelines
4. Submit PR with clear description

---

*Generated by BMAD Document Project Workflow v1.2.0*
