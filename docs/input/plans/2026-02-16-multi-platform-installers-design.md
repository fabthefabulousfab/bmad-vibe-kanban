# Multi-Platform Installer Build System

**Date:** 2026-02-16
**Status:** Approved
**Author:** Amelia (Dev Agent)

## Overview

Create platform-specific installers for bmad-vibe-kanban:
- `launch-bmad-vibe-kanban-macos.sh` (macOS binary)
- `launch-bmad-vibe-kanban-ubuntu.sh` (Ubuntu binary)

Each installer contains only its platform-specific binary, not a unified multi-platform installer.

## Current State

**Existing Infrastructure:**
- `build-vibe-kanban.sh`: Builds Rust backend + frontend
- `local-build.sh`: Auto-detects platform, packages binaries into `npx-cli/dist/{platform}/`
- `build-installer.sh`: Creates self-extracting installer
- Installer runtime: Already has platform detection logic (lines 386-406)

**Problem:**
- Current system only builds for current platform
- Creates generic `launch-bmad-vibe-kanban.sh` filename
- No clear platform identification in output

## Design

### Architecture

```
┌─────────────────────────────────────────────┐
│  build-installer.sh (modified)              │
│  ├─ Detect platform (linux-x64, macos-arm64)│
│  ├─ Check if binary exists                  │
│  ├─ If missing: run build-vibe-kanban.sh    │
│  ├─ Create platform-specific installer      │
│  └─ Output: launch-bmad-...-{platform}.sh   │
└─────────────────────────────────────────────┘
         │
         ├─ On Ubuntu WSL2 → dist/launch-bmad-vibe-kanban-ubuntu.sh
         └─ On macOS       → dist/launch-bmad-vibe-kanban-macos.sh
```

### Platform Detection

Existing `local-build.sh` logic (lines 5-35):
```bash
OS=$(uname -s | tr '[:upper:]' '[:lower:]')  # linux or darwin
ARCH=$(uname -m)                             # x86_64 or arm64

# Maps to: linux-x64, macos-arm64, macos-x64
PLATFORM="${OS}-${ARCH}"
```

### Changes Required

#### 1. build-installer.sh

**Modifications:**
- Add platform detection at start (reuse local-build.sh logic)
- Add `--platform` flag (optional, auto-detect if omitted)
- Change output filename to include platform suffix
- Modify `generate_installer()` to only embed current platform binary
- Remove multi-platform binary embedding logic (lines 993-1017)

**New behavior:**
```bash
# Auto-detect mode (default)
./build-installer.sh
# → dist/launch-bmad-vibe-kanban-linux-x64.sh (on Ubuntu)
# → dist/launch-bmad-vibe-kanban-macos-arm64.sh (on macOS)

# Explicit platform mode
./build-installer.sh --platform macos-arm64
# → dist/launch-bmad-vibe-kanban-macos-arm64.sh
```

#### 2. build-vibe-kanban.sh

**Modifications:**
- Add `export PATH="$HOME/.cargo/bin:$PATH"` for Ubuntu Rust support
- No other changes needed (already platform-aware)

#### 3. Installer Runtime (embedded script)

**Modifications:**
- Simplify platform detection (only one binary embedded, so just verify it matches)
- Remove multi-platform binary markers
- Change from `__VIBE_MACOS_ARM64_START__` to just `__VIBE_BINARY_START__`

### File Changes Summary

```
build-installer.sh        [MODIFY] Platform detection, output naming
build-vibe-kanban.sh      [MODIFY] Add cargo PATH for Ubuntu
bmad-templates/scripts/
  build-installer.sh      [MODIFY] Single-platform embedding logic
```

## Testing Strategy

**Test 1: Ubuntu Build**
```bash
# On Ubuntu WSL2
cd /home/fab/dev/bmad-vibe-kanban
./build-installer.sh
# Expected: dist/launch-bmad-vibe-kanban-linux-x64.sh created
# Verify: Installer contains linux-x64 binary
```

**Test 2: macOS Build** (when available)
```bash
# On macOS
./build-installer.sh
# Expected: dist/launch-bmad-vibe-kanban-macos-arm64.sh created
# Verify: Installer contains macos-arm64 binary
```

**Test 3: Installer Execution**
```bash
# Test Ubuntu installer on Ubuntu
./dist/launch-bmad-vibe-kanban-linux-x64.sh --help
# Expected: Shows help, no errors

# Test installation
mkdir /tmp/test-install && cd /tmp/test-install
/home/fab/dev/bmad-vibe-kanban/dist/launch-bmad-vibe-kanban-linux-x64.sh
# Expected: Installs and launches Vibe Kanban
```

**Test 4: Cross-platform Error Handling**
```bash
# Try running macOS installer on Ubuntu (should fail gracefully)
./launch-bmad-vibe-kanban-macos-arm64.sh
# Expected: Clear error message about platform mismatch
```

## Prerequisites (Ubuntu)

Required tools (verification needed before build):
- Rust + Cargo: `~/.cargo/bin/` (installed)
- Node.js: v24.11.0 (installed)
- pnpm: `npm install -g pnpm` (installed)
- zip: `sudo apt install zip` (installed)

PATH requirements:
```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

## Success Criteria

1. Running `./build-installer.sh` on Ubuntu creates `dist/launch-bmad-vibe-kanban-linux-x64.sh`
2. Running `./build-installer.sh` on macOS creates `dist/launch-bmad-vibe-kanban-macos-arm64.sh`
3. Each installer contains only its platform-specific binary
4. Installer filename clearly identifies target platform
5. All existing functionality preserved (stories, BMAD framework, auto-setup)
6. Build fails gracefully if prerequisites missing

## Non-Goals

- Cross-compilation (build for other platforms from current platform)
- Unified multi-platform installer
- Docker-based builds
- CI/CD automation (can be added later)

## Implementation Notes

**Code simplification opportunities:**
- Remove unused multi-platform binary markers from installer template
- Simplify platform detection in installer runtime (only one binary possible)
- Remove conditional platform embedding logic

**Backwards compatibility:**
- Old generic `launch-bmad-vibe-kanban.sh` will no longer be created
- Users should use platform-specific installers going forward
