# Installer Build Flow

## Problem Statement

When running the installer from `dist/install-bmad-vibe-kanban.sh`, it was launching an **old version** of Vibe Kanban, even though `pnpm run dev` was running the latest version.

**Root Cause:** The installer was embedding old binaries from `npx-cli/dist/` that were not being updated when building the installer.

## Build Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Build Vibe Kanban                                  │
│  Command: ./build-vibe-kanban.sh                            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
    ┌────────────────────────────────────────┐
    │ 1a. Sync stories                       │
    │     bmad-templates/stories/            │
    │          ↓                              │
    │     frontend/public/stories/           │
    └────────────────────────────────────────┘
                          │
                          ▼
    ┌────────────────────────────────────────┐
    │ 1b. Build frontend                     │
    │     cd frontend && pnpm run build      │
    │          ↓                              │
    │     frontend/dist/                     │
    └────────────────────────────────────────┘
                          │
                          ▼
    ┌────────────────────────────────────────┐
    │ 1c. Build Rust backend                 │
    │     cargo build --release              │
    │          ↓                              │
    │     target/release/server (117M)       │
    └────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Step 2: Build Installer                                    │
│  Command: ./build-installer.sh                              │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
    ┌────────────────────────────────────────┐
    │ 2a. Check prerequisites                │
    │     ✓ target/release/server exists     │
    │     ✓ 40 stories synced                │
    └────────────────────────────────────────┘
                          │
                          ▼
    ┌────────────────────────────────────────┐
    │ 2b. Package NPX binaries               │
    │     ./local-build.sh                   │
    │          ↓                              │
    │     Copies target/release/server to:   │
    │     npx-cli/dist/macos-arm64/          │
    │         vibe-kanban.zip (41M)          │
    │         vibe-kanban-mcp.zip (4.7M)     │
    │         vibe-kanban-review.zip (3.9M)  │
    └────────────────────────────────────────┘
                          │
                          ▼
    ┌────────────────────────────────────────┐
    │ 2c. Create installer                   │
    │     bmad-templates/scripts/            │
    │         build-installer.sh             │
    │          ↓                              │
    │     Embeds:                            │
    │     - npx-cli/dist/macos-arm64/*.zip   │
    │     - bmad-templates/stories/          │
    │     - bmad-templates/_bmad/            │
    │     - bmad-templates/.claude/          │
    │     - bmad-templates/scripts/          │
    │          ↓                              │
    │     dist/install-bmad-vibe-kanban.sh   │
    │         (56M self-extracting)          │
    └────────────────────────────────────────┘
```

## Critical Step: NPX Packaging (local-build.sh)

**Location:** `/Users/fabulousfab/Dev/agents/vibe-kanban/local-build.sh`

**What it does:**
1. Detects platform (macos-arm64, linux-x64, etc.)
2. Builds frontend (if needed)
3. Builds Rust binaries (if needed)
4. **Copies** `target/release/server` → `npx-cli/dist/$PLATFORM/vibe-kanban.zip`
5. Copies MCP and Review binaries

**Why it's critical:**
- The installer embeds binaries from `npx-cli/dist/`, NOT `target/release/`
- Without running `local-build.sh`, old binaries stay in `npx-cli/dist/`
- Result: Installer packages OLD version

## The Bug (Before Fix)

**build-installer.sh** (lines 56-58):
```bash
cd "$PROJECT_ROOT/npx-cli"
if [ -f "./local-build.sh" ]; then  # ❌ WRONG PATH
  ./local-build.sh
```

**Problem:**
- Script looks for `local-build.sh` in `npx-cli/` directory
- File is actually at project root
- Condition fails, `local-build.sh` never runs
- Old binaries in `npx-cli/dist/` get packaged

## The Fix

**build-installer.sh** (lines 56-60):
```bash
cd "$PROJECT_ROOT"                  # ✓ CORRECT: Go to root
if [ -f "./local-build.sh" ]; then  # ✓ CORRECT: Find file
  echo "      Running local-build.sh to package binaries..."
  ./local-build.sh                  # ✓ CORRECT: Run packaging
  echo "      ✓ NPX package built"
```

## Verification

### Before Fix
```bash
$ ls -lah npx-cli/dist/macos-arm64/
-rw-r--r-- ... Feb 15 19:59 vibe-kanban.zip  # OLD (19:59)

$ ls -lah target/release/server
-rwxr-xr-x ... Feb 15 21:16 server            # NEW (21:16)
```

**Gap:** 1 hour 17 minutes between latest build and packaged binary!

### After Fix
```bash
$ ./build-installer.sh
[2/3] Building NPX package...
      Running local-build.sh to package binaries...
      ✓ NPX package built

$ ls -lah npx-cli/dist/macos-arm64/
-rw-r--r-- ... Feb 15 21:56 vibe-kanban.zip  # FRESH!
```

## Complete Build Workflow

### Development (Hot Reload)
```bash
# Frontend dev with hot reload
cd frontend && pnpm run dev
# Backend dev with auto-restart
pnpm run backend:dev:watch
```
**Result:** Latest code, instant updates

### Production Build
```bash
# Step 1: Build Vibe Kanban binary
./build-vibe-kanban.sh
# Result: target/release/server (117M)

# Step 2: Build installer (includes Step 1 output)
./build-installer.sh
# Result: dist/install-bmad-vibe-kanban.sh (56M)
```
**Result:** Installer with latest code

### Testing Installer
```bash
# Test in clean directory
mkdir /tmp/test && cd /tmp/test
~/path/to/vibe-kanban/dist/install-bmad-vibe-kanban.sh --skip-deps --no-autostart

# Verify extraction
ls -la  # Should show: _bmad/, .claude/, stories/, templates/, scripts/
```

## File Sizes Reference

| File | Size | Contents |
|------|------|----------|
| `target/release/server` | 117M | Rust binary with embedded frontend |
| `npx-cli/dist/macos-arm64/vibe-kanban.zip` | 41M | Compressed binary |
| `dist/install-bmad-vibe-kanban.sh` | 56M | Self-extracting installer |

## Common Issues

### Issue 1: Installer has old version
**Symptom:** Running installer launches old Vibe Kanban
**Cause:** `npx-cli/dist/` not updated
**Fix:** Run `./build-installer.sh` (which now runs `local-build.sh`)

### Issue 2: Manual binary update needed
**Symptom:** Changed code but installer still has old version
**Cause:** Forgot to rebuild
**Fix:**
```bash
./build-vibe-kanban.sh  # Rebuild binary
./build-installer.sh    # Rebuild installer (auto-packages binary)
```

### Issue 3: npx-cli/dist/ missing
**Symptom:** Installer build fails with "binary not found"
**Cause:** Never ran `local-build.sh`
**Fix:**
```bash
./local-build.sh        # Create npx-cli/dist/
./build-installer.sh    # Build installer
```

## Development Tips

1. **After code changes:**
   ```bash
   ./build-vibe-kanban.sh && ./build-installer.sh
   ```

2. **Quick test (no installer):**
   ```bash
   ./build-vibe-kanban.sh
   ./target/release/server
   ```

3. **Verify installer version:**
   ```bash
   ls -lah npx-cli/dist/macos-arm64/*.zip
   # Check timestamps match latest build
   ```

4. **Force rebuild:**
   ```bash
   rm -rf npx-cli/dist target/release/server
   ./build-vibe-kanban.sh
   ./build-installer.sh
   ```

## Related Files

- `build-vibe-kanban.sh` - Builds Rust binary (target/release/server)
- `build-installer.sh` - Builds installer (packages binary)
- `local-build.sh` - Packages binary into npx-cli/dist/
- `bmad-templates/scripts/build-installer.sh` - Creates self-extracting installer
- `quick-check.sh` - Validates repository state

## Last Updated

- **Date:** 2026-02-15
- **Commit:** 53c6f0b0
- **Issue:** Fixed installer embedding old binaries
- **Status:** ✅ Working correctly
