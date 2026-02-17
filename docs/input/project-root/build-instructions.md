# Build Instructions

## Prerequisites

### Ubuntu/Linux
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# Install Node.js (if not installed)
# Use nvm or your preferred method

# Install pnpm
npm install -g pnpm

# Install build dependencies
sudo apt-get update
sudo apt-get install build-essential pkg-config libssl-dev libclang-dev zip
```

### macOS
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# Install Node.js (if not installed)
# Use nvm or your preferred method

# Install pnpm
npm install -g pnpm

# zip is pre-installed on macOS
# build tools installed via Xcode Command Line Tools
```

## Building the Installer

### On Ubuntu
```bash
./build-installer.sh
# Creates: dist/launch-bmad-vibe-kanban-linux-x64.sh
```

### On macOS (Intel)
```bash
./build-installer.sh
# Creates: dist/launch-bmad-vibe-kanban-macos-x64.sh
```

### On macOS (Apple Silicon)
```bash
./build-installer.sh
# Creates: dist/launch-bmad-vibe-kanban-macos-arm64.sh
```

## Platform Detection

The build system automatically detects your platform:
- Linux x86_64 → `linux-x64`
- macOS Intel → `macos-x64`
- macOS Apple Silicon → `macos-arm64`

Each installer contains only the binary for its target platform.

## Testing the Installer

```bash
# Show help
./dist/launch-bmad-vibe-kanban-<platform>.sh --help

# Dry run (no services started)
./dist/launch-bmad-vibe-kanban-<platform>.sh --dry-run --verbose

# Full installation
./dist/launch-bmad-vibe-kanban-<platform>.sh
```

## Distribution

Upload platform-specific installers to GitHub Releases:
- `launch-bmad-vibe-kanban-linux-x64.sh` (for Ubuntu/Debian)
- `launch-bmad-vibe-kanban-macos-arm64.sh` (for Apple Silicon Macs)
- `launch-bmad-vibe-kanban-macos-x64.sh` (for Intel Macs)

## Troubleshooting

### Ubuntu Build Issues

**Missing C compiler:**
```bash
sudo apt-get install build-essential
```

**Missing pkg-config:**
```bash
sudo apt-get install pkg-config
```

**Missing OpenSSL:**
```bash
sudo apt-get install libssl-dev
```

**Missing libclang:**
```bash
sudo apt-get install libclang-dev
```

### macOS Build Issues

**Cargo not found:**
```bash
source "$HOME/.cargo/env"
# Or restart your terminal
```

**Xcode Command Line Tools:**
```bash
xcode-select --install
```
