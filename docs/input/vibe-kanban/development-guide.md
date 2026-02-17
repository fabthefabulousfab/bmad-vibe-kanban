# Development Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation and Setup](#installation-and-setup)
3. [Development Commands](#development-commands)
4. [Build Process](#build-process)
5. [Testing](#testing)
6. [Docker Build](#docker-build)
7. [Release and Deployment](#release-and-deployment)
8. [Common Development Tasks](#common-development-tasks)
9. [Code Style Rules](#code-style-rules)
10. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

| Tool | Version | Purpose |
|------|---------|---------|
| **Node.js** | >= 18 | JavaScript runtime for frontend |
| **pnpm** | >= 8, exact: 10.13.1 | Package manager |
| **Rust** | nightly-2025-12-04 | Backend compilation |
| **Cargo** | (included with Rust) | Rust package manager |
| **Git** | Latest | Version control |

### Rust Toolchain Components

The following Rust components are required (specified in `rust-toolchain.toml`):

- `rustfmt` - Code formatting
- `rustc` - Rust compiler
- `rust-analyzer` - IDE support
- `rust-src` - Source code for standard library
- `rust-std` - Standard library
- `cargo` - Package manager

### Optional Tools

| Tool | Purpose |
|------|---------|
| **cargo-watch** | Auto-rebuild on file changes |
| **sqlx-cli** | Database migrations (SQLite + PostgreSQL support) |
| **cargo-edit** | Version management |
| **Docker** | Container builds |

### Platform-Specific Dependencies

**Linux:**
```bash
sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
  clang libclang-dev lld llvm nasm cmake ninja-build
```

**macOS:**
- Xcode Command Line Tools: `xcode-select --install`
- No additional dependencies required

**Windows:**
- Visual Studio 2019+ with C++ build tools
- LLVM/Clang (for some dependencies)

## Installation and Setup

### 1. Clone Repository

```bash
git clone https://github.com/fabthefabulousfab/bmad-vibe-kanban.git
cd bmad-vibe-kanban
```

### 2. Install Node Dependencies

```bash
pnpm install
```

This installs dependencies for:
- Root workspace (concurrently)
- Frontend (React 18, Vite, TailwindCSS, Vitest)
- NPX CLI wrapper

### 3. Install Rust Toolchain

The Rust toolchain is automatically installed via `rust-toolchain.toml` when you run Cargo commands. To manually install:

```bash
rustup toolchain install nightly-2025-12-04
rustup default nightly-2025-12-04
rustup component add rustfmt rust-analyzer rust-src
```

### 4. Install Optional Cargo Tools

```bash
# For auto-rebuild during development
cargo install cargo-watch

# For database migrations
cargo install sqlx-cli --no-default-features --features sqlite,postgres

# For version bumping
cargo install cargo-edit
```

### 5. Prepare Database

```bash
pnpm run prepare-db
```

This generates SQL migration files for the local SQLite database.

### 6. Verify Setup

```bash
./quick-check.sh
```

This validates:
- Directory structure
- Story templates (35+ files)
- Build scripts
- Story services
- BMAD framework

## Development Commands

### Root Workspace Commands

| Command | Description |
|---------|-------------|
| `pnpm run dev` | Start frontend + backend in watch mode |
| `pnpm run dev:qa` | Start with QA mode enabled |
| `pnpm run lint` | Lint frontend and backend |
| `pnpm run format` | Format all code (Rust + TypeScript) |
| `pnpm run check` | Type-check frontend and backend |
| `pnpm run test:npm` | Test NPM package distribution |

### Frontend Commands

| Command | Description |
|---------|-------------|
| `cd frontend && pnpm run dev` | Start Vite dev server (port from env) |
| `pnpm run build` | Build production frontend |
| `pnpm run check` | TypeScript type checking |
| `pnpm run test` | Run Vitest tests in watch mode |
| `pnpm run test:ui` | Run Vitest with UI |
| `pnpm run test:run` | Run tests once (CI mode) |
| `pnpm run lint` | ESLint with strict rules |
| `pnpm run lint:fix` | Auto-fix ESLint issues |
| `pnpm run lint:i18n` | Validate i18n translations |
| `pnpm run format` | Prettier formatting |
| `pnpm run format:check` | Check formatting without modifying |
| `pnpm run preview` | Preview production build |

### Backend Commands

| Command | Description |
|---------|-------------|
| `pnpm run backend:dev` | Start backend dev server |
| `pnpm run backend:dev:watch` | Auto-rebuild backend on changes |
| `pnpm run backend:lint` | Clippy linting (strict mode) |
| `pnpm run backend:check` | Check Rust compilation |
| `cargo test --workspace` | Run all Rust tests |
| `cargo fmt --all` | Format Rust code |

### Type Generation Commands

| Command | Description |
|---------|-------------|
| `pnpm run generate-types` | Generate TypeScript types from Rust (ts-rs) |
| `pnpm run generate-types:check` | Verify types are up-to-date |
| `pnpm run remote:generate-types` | Generate types for remote server |

### Database Commands

| Command | Description |
|---------|-------------|
| `pnpm run prepare-db` | Generate SQL migrations for local server |
| `pnpm run prepare-db:check` | Verify migrations are up-to-date |
| `pnpm run remote:prepare-db` | Generate migrations for remote server |

### Remote Server Commands

| Command | Description |
|---------|-------------|
| `pnpm run remote:dev` | Start remote server via Docker Compose |
| `pnpm run remote:dev:clean` | Stop and remove remote containers |

## Build Process

### Full Build Workflow

The complete build process involves three stages:

#### 1. Story Synchronization

```bash
# Automatically run by build-vibe-kanban.sh
rsync -a --delete \
  bmad-templates/stories/ \
  frontend/public/stories/
```

Stories are synced from source (`bmad-templates/stories/`) to the frontend public directory. The build script also updates story manifests in `storyParser.ts`.

#### 2. Frontend Build

```bash
cd frontend
pnpm run build
```

**Build Steps:**
1. TypeScript compilation (`tsc`)
2. Vite bundling (Rollup)
3. Asset optimization
4. Story embedding (markdown files)

**Output:** `frontend/dist/` (embedded in Rust binary)

**Environment Variables:**
- `VITE_POSTHOG_API_KEY` - Analytics key (optional)
- `VITE_POSTHOG_API_ENDPOINT` - Analytics endpoint (optional)
- `VITE_VK_SHARED_API_BASE` - Remote API base URL
- `SENTRY_AUTH_TOKEN` - Error tracking token (optional)

#### 3. Backend Build

```bash
cargo build --release
```

**Build Steps:**
1. Frontend embedding via RustEmbed
2. Dependency compilation (10 crates)
3. Binary linking
4. Debug symbol stripping (release profile)

**Output:** `target/release/server` (standalone binary with embedded frontend)

**Crates Built:**
- `server` - Main HTTP server (Axum)
- `db` - Database layer (SQLite)
- `executors` - AI executor implementations
- `services` - Business logic
- `utils` - Shared utilities
- `git` - Git operations
- `local-deployment` - Local deployment
- `deployment` - Deployment abstractions
- `review` - Code review CLI

### Automated Build Scripts

#### build-vibe-kanban.sh

Complete build with story synchronization:

```bash
./build-vibe-kanban.sh
```

**Steps:**
1. Sync stories from `bmad-templates/stories/` to `frontend/public/stories/`
2. Update story manifests in `storyParser.ts`
3. Clean and rebuild frontend
4. Clean server cache and rebuild backend
5. Output summary with artifact sizes

**Output:**
- `target/release/server` - Backend binary (~50-80MB)
- `frontend/dist/` - Frontend assets (embedded)
- Story markdown files (35+ files embedded)

#### local-build.sh

Platform-specific NPX package build:

```bash
./local-build.sh
```

**Steps:**
1. Detect platform (linux-x64, macos-arm64, etc.)
2. Build frontend (if not already built)
3. Build Rust binaries (server, mcp_task_server, review)
4. Create platform-specific ZIP packages
5. Output to `npx-cli/dist/{platform}/`

**Output:**
- `npx-cli/dist/{platform}/vibe-kanban.zip`
- `npx-cli/dist/{platform}/vibe-kanban-mcp.zip`
- `npx-cli/dist/{platform}/vibe-kanban-review.zip`

### Build Optimization

**Release Profile** (`Cargo.toml`):
```toml
[profile.release]
debug = 1                 # Include debug symbols for Sentry
split-debuginfo = "packed" # Separate debug info
strip = true              # Strip symbols from binary
```

**Frontend Optimization:**
- Code splitting via dynamic imports
- Tree shaking (Rollup)
- Asset compression
- React compiler (experimental)

## Testing

### Frontend Testing

**Test Framework:** Vitest + Testing Library

```bash
cd frontend

# Watch mode (default)
pnpm run test

# UI mode
pnpm run test:ui

# CI mode (single run)
pnpm run test:run
```

**Test Structure:**
- Unit tests: Component logic, utilities
- Integration tests: Component interactions
- Coverage target: 80% minimum

**Test Files:** `*.test.ts`, `*.test.tsx` (co-located with source)

### Backend Testing

**Test Framework:** Rust built-in testing

```bash
# All workspace tests
cargo test --workspace

# Specific crate
cargo test -p server

# With output
cargo test -- --nocapture

# Specific test
cargo test test_name
```

**Test Structure:**
- Unit tests: In same file as implementation (`#[cfg(test)]`)
- Integration tests: In `tests/` directories
- Doctests: In documentation comments

### Linting and Formatting

**Frontend:**
```bash
cd frontend

# ESLint
pnpm run lint
pnpm run lint:fix

# i18n validation
pnpm run lint:i18n

# Prettier
pnpm run format
pnpm run format:check
```

**Backend:**
```bash
# Clippy (strict mode)
pnpm run backend:lint
# Equivalent to:
cargo clippy --workspace --all-targets --features qa-mode -- -D warnings

# Rustfmt
cargo fmt --all
cargo fmt --all -- --check  # CI mode
```

### CI Testing Pipeline

**Workflow:** `.github/workflows/test.yml`

**Jobs:**
1. **Lint frontend** - ESLint with max warnings = 0
2. **Check i18n** - Regression detection in translations
3. **Format check** - Prettier validation
4. **Type check** - TypeScript compilation
5. **Build frontend** - Production build
6. **Rust checks:**
   - `cargo fmt --check`
   - `generate-types:check`
   - `prepare-db:check`
   - `cargo test --workspace`
   - `cargo clippy` (all targets, strict warnings)

**Environment:**
- Runner: `buildjet-8vcpu-ubuntu-2204`
- Node: 22
- pnpm: 10.13.1
- Rust: nightly-2025-12-04
- Cache: Rust dependencies, cargo binaries

## Docker Build

### Dockerfile

**Multi-stage build:**

#### Stage 1: Builder

```dockerfile
FROM node:24-alpine AS builder

# Install Rust + build dependencies
RUN apk add --no-cache curl build-base perl llvm-dev clang-dev
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Build application
RUN npm install -g pnpm && pnpm install
RUN npm run generate-types
RUN cd frontend && pnpm run build
RUN cargo build --release --bin server
```

#### Stage 2: Runtime

```dockerfile
FROM alpine:latest AS runtime

# Runtime dependencies only
RUN apk add --no-cache ca-certificates tini libgcc wget

# Non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy binary
COPY --from=builder /app/target/release/server /usr/local/bin/server

# Run as appuser
USER appuser
EXPOSE 3000
CMD ["server"]
```

### Build and Run

```bash
# Build image
docker build -t vibe-kanban:latest .

# Run container
docker run -p 3000:3000 \
  -v $(pwd)/repos:/repos \
  vibe-kanban:latest

# Health check
curl http://localhost:3000
```

**Environment Variables:**
- `HOST` - Bind address (default: 0.0.0.0)
- `PORT` - HTTP port (default: 3000)
- `POSTHOG_API_KEY` - Analytics (optional)
- `POSTHOG_API_ENDPOINT` - Analytics endpoint (optional)

## Release and Deployment

### Release Pipeline

**Workflow:** `.github/workflows/pre-release.yml`

**Trigger:** Manual workflow dispatch with version type:
- `patch` - Bug fixes (0.1.4 → 0.1.5)
- `minor` - New features (0.1.4 → 0.2.0)
- `major` - Breaking changes (0.1.4 → 1.0.0)
- `prerelease` - Pre-release (0.1.4 → 0.1.5-branch.timestamp)

### Build Matrix

**6-platform matrix:**

| Platform | Target | Runner | Build Tool |
|----------|--------|--------|------------|
| linux-x64 | x86_64-unknown-linux-musl | ubuntu-latest-x64-l | cargo-zigbuild |
| linux-arm64 | aarch64-unknown-linux-musl | ubuntu-latest-arm64-l | cargo-zigbuild |
| windows-x64 | x86_64-pc-windows-msvc | ubuntu-latest-x64-l | cargo-xwin |
| windows-arm64 | aarch64-pc-windows-msvc | ubuntu-latest-x64-l | cargo-xwin |
| macos-x64 | x86_64-apple-darwin | macos-15-xlarge | cargo |
| macos-arm64 | aarch64-apple-darwin | macos-15-xlarge | cargo |

### Release Jobs

#### 1. bump-version

- Compare npm registry vs repo version
- Bump version in all `package.json` and `Cargo.toml` files
- Update lockfiles
- Create git tag (e.g., `v0.1.5-20260217123456`)
- Push to repository

#### 2. build-frontend

- Checkout tagged version
- Install dependencies
- Lint and type-check
- Build with Sentry sourcemaps
- Upload artifact for backend builds

#### 3. build-backend (matrix)

**Per-platform steps:**
1. Setup Rust toolchain with target
2. Install platform-specific tools:
   - Linux: Zig + cargo-zigbuild (musl builds)
   - Windows: LLVM 19 + cargo-xwin (cross-compile from Linux)
   - macOS: Native cargo (self-hosted runner)
3. Download frontend artifact
4. Build binaries:
   - `server` - Main Vibe Kanban server
   - `mcp_task_server` - MCP protocol server
   - `review` - Code review CLI
5. Upload debug symbols to Sentry
6. macOS only: Code sign + notarize with Apple certificate
7. Upload platform binaries as artifacts

**Optimizations:**
- sccache for compilation caching
- Rust toolchain caching
- Cargo registry caching
- Target directory caching
- cargo-sweep for size limits (10GB max, 30-day retention)

#### 4. package-npx-cli (matrix)

- Download frontend + platform binaries
- Create platform-specific packages:
  - Unzip macOS signed binaries
  - Zip other platform binaries
- Upload to artifacts

#### 5. upload-to-r2

- Download all platform packages
- Generate manifest with SHA256 checksums
- Upload to Cloudflare R2:
  - `binaries/{tag}/{platform}/vibe-kanban.zip`
  - `binaries/{tag}/{platform}/vibe-kanban-mcp.zip`
  - `binaries/{tag}/{platform}/vibe-kanban-review.zip`
  - `binaries/{tag}/manifest.json`
  - `binaries/manifest.json` (global latest)

#### 6. create-prerelease

- Inject R2 URL + tag into `npx-cli/bin/download.js`
- Run `npm pack` for npx-cli
- Create GitHub pre-release with:
  - Frontend dist ZIP
  - NPM package tarball
  - Auto-generated release notes

### NPM Publishing

**Manual step after testing pre-release:**

```bash
cd npx-cli
npm publish
```

The `npx-cli` package:
- Downloads platform-specific binaries from R2 on first run
- Caches in `~/.vibe-kanban/bin/`
- Executes local server with frontend embedded

## Common Development Tasks

### Adding a New Feature

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Develop with hot reload
pnpm run dev

# 3. Write tests
cd frontend && pnpm run test
cargo test -p {crate}

# 4. Lint and format
pnpm run lint
pnpm run format

# 5. Type-check
pnpm run check

# 6. Build to verify
./build-vibe-kanban.sh

# 7. Test binary
./target/release/server
```

### Modifying BMAD Stories

```bash
# 1. Edit story in source
vim bmad-templates/stories/workflow-complet/1-1-0-brainstorm.md

# 2. Rebuild (auto-syncs stories)
./build-vibe-kanban.sh

# 3. Test in dev mode
cd frontend && pnpm run dev
# Stories available at http://localhost:3000/stories/
```

### Adding TypeScript Types from Rust

```bash
# 1. Add #[derive(Serialize, TS)] to Rust struct
# 2. Add #[ts(export)] attribute

# Example:
# #[derive(Serialize, TS)]
# #[ts(export)]
# struct MyType { ... }

# 3. Generate types
pnpm run generate-types

# 4. Verify
pnpm run generate-types:check

# 5. Import in TypeScript
# import { MyType } from '@/types/generated'
```

### Database Schema Changes

```bash
# 1. Modify schema in crates/db/src/schema.rs

# 2. Generate migrations
pnpm run prepare-db

# 3. Verify
pnpm run prepare-db:check

# 4. Test
cargo test -p db
```

### Testing NPX Distribution

```bash
# 1. Build local package
./local-build.sh

# 2. Test CLI
cd npx-cli
node bin/cli.js

# 3. Test package install
pnpm run test:npm
```

### Creating a Release

```bash
# 1. Ensure main branch is clean
git checkout main
git pull

# 2. Trigger workflow
# Go to GitHub Actions → "Create GitHub Pre-Release"
# Choose version type (patch/minor/major/prerelease)

# 3. Monitor build (10-20 minutes)

# 4. Test pre-release
curl -L https://github.com/fabthefabulousfab/bmad-vibe-kanban/releases/download/v{tag}/launch-bmad-vibe-kanban.sh | bash

# 5. Publish to npm (if stable)
gh release download v{tag} -p "vibe-kanban-*.tgz"
npm publish vibe-kanban-{version}.tgz
```

## Code Style Rules

### TypeScript/React (Frontend)

**Based on:** `frontend/CLAUDE.md`

#### Architecture

- **View components** (`views/`) - Stateless, receive data via props
- **Container components** (`containers/`) - Manage state, pass to views
- **UI components** (`ui-new/`) - Reusable primitives
- **File naming:** PascalCase for UI components (e.g., `Field.tsx`)

#### Styling

**Design system:** New design with CSS variables (`.new-design` class)

**Colors:**
- Text: `text-high`, `text-normal`, `text-low`
- Background: `bg-primary`, `bg-secondary`, `bg-panel`
- Accent: `brand`, `error`, `success`

**Typography:**
- Fonts: `font-ibm-plex-sans`, `font-ibm-plex-mono`
- Sizes: `text-xs` (8px), `text-sm` (10px), `text-base` (12px)

**Spacing:**
- `p-half` / `m-half` (6px)
- `p-base` / `m-base` (12px)
- `p-double` / `m-double` (24px)

### Rust (Backend)

**Based on:** `.claude/CLAUDE.md`

#### Code Organization

- Many small files (200-400 lines typical, 800 max)
- High cohesion, low coupling
- Organize by feature/domain, not by type

#### Code Style

- Immutability preferred
- Proper error handling with `Result<T, E>`
- Input validation
- Simple patterns over complex architecture
- Document everything
- Add logs at function entry/exit

#### Testing

- TDD approach
- 80% minimum coverage
- Unit tests for utilities
- Integration tests for APIs
- E2E tests for critical flows

### Git Workflow

**Commit conventions:**
```
feat: Add new feature
fix: Bug fix
refactor: Code restructuring
docs: Documentation only
test: Add or update tests
chore: Build process or tooling
```

**Branch strategy:**
- Never commit to `main` directly
- Feature branches: `feature/description`
- Bugfix branches: `fix/description`
- PRs require review
- All tests must pass before merge

### Security Rules

- No hardcoded secrets
- Environment variables for sensitive data
- Validate all user inputs
- Parameterized queries only (SQLx compile-time checks)
- CSRF protection enabled

## Troubleshooting

### Common Issues

#### Frontend build fails with memory error

```bash
# Increase Node.js heap size
NODE_OPTIONS=--max-old-space-size=8192 pnpm run build
```

#### RustEmbed not picking up frontend changes

```bash
# Clean server package cache
cargo clean -p server
./build-vibe-kanban.sh
```

#### Stories not appearing in UI

```bash
# Verify sync
./quick-check.sh

# Force rebuild
rm -rf frontend/dist/
./build-vibe-kanban.sh
```

#### Type generation fails

```bash
# Check Rust compilation first
cargo check

# Then regenerate
pnpm run generate-types
```

#### Database migration errors

```bash
# Regenerate migrations
pnpm run prepare-db

# Clean database
rm -rf ~/.vibe-kanban/db/
```

#### Port already in use

```bash
# Find process using port
lsof -i :3000
kill -9 {PID}

# Or change port
BACKEND_PORT=3001 pnpm run dev
```

#### Cargo build fails on macOS

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Update Rust
rustup update
```

#### pnpm install fails

```bash
# Clear cache
pnpm store prune

# Remove node_modules and lockfile
rm -rf node_modules/ pnpm-lock.yaml

# Reinstall
pnpm install
```

### Debug Mode

**Frontend:**
```bash
# Enable React DevTools
VITE_OPEN=true pnpm run dev
```

**Backend:**
```bash
# Enable debug logging
RUST_LOG=debug cargo run --bin server

# Trace-level logging
RUST_LOG=trace cargo run --bin server

# Disable worktree cleanup (development)
DISABLE_WORKTREE_CLEANUP=1 cargo run --bin server
```

### Build Performance

**Rust compilation:**
```bash
# Use sccache (GitHub Actions uses this)
export RUSTC_WRAPPER=sccache
export SCCACHE_CACHE_SIZE=10G

# Parallel compilation (default: CPU cores)
export CARGO_BUILD_JOBS=8

# Incremental compilation (development only)
export CARGO_INCREMENTAL=1
```

**Frontend build:**
```bash
# Disable source maps for faster builds
VITE_SOURCEMAP=false pnpm run build

# Skip type checking during build
pnpm run build --mode production
```

### Logs and Diagnostics

**Log locations:**
- Frontend: Browser console
- Backend: stdout/stderr
- CI: GitHub Actions logs
- Production: Sentry (if configured)

**Health checks:**
```bash
# Backend health
curl http://localhost:3000

# Docker health
docker inspect --format='{{.State.Health}}' {container}
```

---

*Generated by BMAD Document Project Workflow v1.2.0 (Deep Scan)*
