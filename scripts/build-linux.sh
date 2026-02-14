#!/bin/bash
# Build vibe-kanban for Linux (Ubuntu) using Docker
# Usage: ./scripts/build-linux.sh
#
# This script builds the Rust binaries inside a Docker container to produce
# Linux-compatible binaries from any host OS.
# The frontend is platform-independent and uses the existing build.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🐳 Building vibe-kanban for Linux using Docker..."
echo "📁 Project root: $PROJECT_ROOT"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed."
    echo "   Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if frontend is built
if [ ! -d "$PROJECT_ROOT/frontend/dist" ]; then
    echo "❌ Frontend not built. Please run 'pnpm run build:npx' first or build the frontend."
    exit 1
fi

# Create a Dockerfile for building Rust only
DOCKERFILE=$(mktemp)
cat > "$DOCKERFILE" << 'DOCKERFILE_CONTENT'
FROM rust:1.83-bookworm

# Install build dependencies (including libclang for bindgen and sqlite3)
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    libsqlite3-dev \
    libclang-dev \
    clang \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Pre-install the nightly toolchain required by the project
RUN rustup install nightly-2025-12-04 && \
    rustup default nightly-2025-12-04

WORKDIR /app

# Copy only what's needed for Rust build (excluding node_modules, frontend/dist which are large)
COPY Cargo.toml Cargo.lock ./
COPY crates ./crates
COPY assets ./assets
COPY frontend/dist ./frontend/dist

# Build
ENV VK_SHARED_API_BASE="https://api.vibekanban.com"

CMD ["bash", "-c", "\
    mkdir -p npx-cli/dist/linux-x64 && \
    cargo build --release && \
    cargo build --release --bin mcp_task_server && \
    cp target/release/server vibe-kanban && \
    zip -q vibe-kanban.zip vibe-kanban && \
    rm -f vibe-kanban && \
    mv vibe-kanban.zip npx-cli/dist/linux-x64/ && \
    cp target/release/mcp_task_server vibe-kanban-mcp && \
    zip -q vibe-kanban-mcp.zip vibe-kanban-mcp && \
    rm -f vibe-kanban-mcp && \
    mv vibe-kanban-mcp.zip npx-cli/dist/linux-x64/ && \
    cp target/release/review vibe-kanban-review && \
    zip -q vibe-kanban-review.zip vibe-kanban-review && \
    rm -f vibe-kanban-review && \
    mv vibe-kanban-review.zip npx-cli/dist/linux-x64/ && \
    echo '✅ Linux Rust build complete!' \
"]
DOCKERFILE_CONTENT

# Create a .dockerignore to speed up the build
DOCKERIGNORE=$(mktemp)
cat > "$DOCKERIGNORE" << 'DOCKERIGNORE_CONTENT'
node_modules
target
.git
*.md
npx-cli/dist
frontend/node_modules
frontend/src
DOCKERIGNORE_CONTENT
cp "$DOCKERIGNORE" "$PROJECT_ROOT/.dockerignore.linux"

# Build the Docker image (explicitly for linux/amd64 platform)
echo "🔨 Building Docker image for linux/amd64..."
docker build --platform linux/amd64 -t vibe-kanban-linux-builder -f "$DOCKERFILE" "$PROJECT_ROOT"

# Run the build and extract the output
echo "🚀 Running Rust build inside container..."
CONTAINER_ID=$(docker create --platform linux/amd64 vibe-kanban-linux-builder)
docker start -a "$CONTAINER_ID"

# Copy the built files from the container
echo "📦 Extracting build artifacts..."
mkdir -p "$PROJECT_ROOT/npx-cli/dist/linux-x64"
docker cp "$CONTAINER_ID:/app/npx-cli/dist/linux-x64/." "$PROJECT_ROOT/npx-cli/dist/linux-x64/"

# Cleanup
docker rm "$CONTAINER_ID" > /dev/null
rm "$DOCKERFILE"
rm "$DOCKERIGNORE"
rm -f "$PROJECT_ROOT/.dockerignore.linux"

echo ""
echo "✅ Linux build complete!"
echo "📁 Files created:"
ls -la "$PROJECT_ROOT/npx-cli/dist/linux-x64/"
