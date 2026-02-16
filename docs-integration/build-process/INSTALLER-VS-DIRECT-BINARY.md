# Installer vs Direct Binary - Behavior Differences

## Problem Statement

When testing Vibe Kanban, you may notice different behavior:
- **Direct binary** (`./target/release/server`): Works correctly ✅
- **Installer** (`dist/install-bmad-vibe-kanban.sh`): Shows different UI or behavior ❌

This document explains why and how to fix it.

## Root Cause

The installer packages binaries through `local-build.sh`, which was REBUILDING the frontend and backend even when they were already built by `build-vibe-kanban.sh`.

### The Problem Flow (Before Fix)

```
1. ./build-vibe-kanban.sh
   ├─ Syncs stories (latest)
   ├─ Builds frontend with latest code (22:05)
   └─ Builds backend (22:06)
   Result: target/release/server ✅ LATEST

2. ./build-installer.sh
   └─ Calls local-build.sh
      ├─ REBUILDS frontend (could be different!)
      ├─ REBUILDS backend (could be different!)
      └─ Packages into npx-cli/dist/
      Result: Packaged binary ⚠️ DIFFERENT

3. Installer extracts and runs packaged binary
   Result: Different behavior than direct binary ❌
```

### Why Rebuilding is Bad

1. **Inconsistent state**: Frontend could rebuild from different code state
2. **Cache issues**: npm/vite cache could serve stale assets
3. **Race conditions**: Files modified between builds
4. **Version drift**: git state could change between builds

## The Fix

Modified `local-build.sh` to check if binaries already exist:

```bash
# Before (always rebuild)
echo "🔨 Building frontend..."
(cd frontend && npm run build)
echo "🔨 Building Rust binaries..."
cargo build --release

# After (check first)
if [ -f "${CARGO_TARGET_DIR}/release/server" ]; then
  echo "ℹ️  Using existing binaries (skip rebuild)"
else
  echo "🔨 Building frontend..."
  (cd frontend && npm run build)
  echo "🔨 Building Rust binaries..."
  cargo build --release
fi
```

## Correct Workflow

### For Development Testing

```bash
# Step 1: Build Vibe Kanban
./build-vibe-kanban.sh

# Step 2: Test direct binary
./target/release/server
# Verify: Open http://127.0.0.1:3001
# Test: Click '+' button → Select Workflow → Execute
# Expected: Stories imported correctly ✅

# Step 3: Build installer (uses same binary)
./build-installer.sh

# Step 4: Test installer
cd /tmp/test
~/path/to/dist/install-bmad-vibe-kanban.sh --skip-deps --no-autostart
# Expected: Same behavior as direct binary ✅
```

### If Behaviors Still Differ

**Symptom:** Direct binary works but installer doesn't

**Diagnosis Steps:**

1. **Check if frontend was rebuilt:**
```bash
# Look for this in installer build output
ls -lah frontend/dist/index.html
ls -lah target/release/server

# Timestamps should match build-vibe-kanban.sh run
# If different, local-build.sh rebuilt!
```

2. **Force clean rebuild:**
```bash
# Remove all build artifacts
rm -rf frontend/dist target/release npx-cli/dist dist/

# Rebuild from scratch
./build-vibe-kanban.sh
./build-installer.sh
```

3. **Check binary is same:**
```bash
# Compare direct and packaged binaries
md5 target/release/server

# Extract from zip
cd /tmp
unzip ~/path/to/npx-cli/dist/macos-arm64/vibe-kanban.zip
md5 vibe-kanban

# Should be IDENTICAL
```

4. **Verify stories are embedded:**
```bash
# Check direct binary
strings target/release/server | grep "workflow-complet" | head -5

# Check packaged binary
cd /tmp
unzip ~/path/to/npx-cli/dist/macos-arm64/vibe-kanban.zip
strings vibe-kanban | grep "workflow-complet" | head -5

# Should show same story filenames
```

## Common Issues

### Issue 1: Old Frontend in Installer

**Symptom:** Installer shows old UI or missing features

**Cause:** Frontend was rebuilt with old code

**Fix:**
```bash
# Clean frontend cache
rm -rf frontend/dist frontend/.vite frontend/node_modules/.vite

# Rebuild
./build-vibe-kanban.sh
./build-installer.sh
```

### Issue 2: Stories Not Found

**Symptom:** "Select Workflow" button shows shell script menu instead of story list

**Cause:** Stories not embedded in binary

**Fix:**
```bash
# Verify stories are in frontend dist
ls -la frontend/public/stories/
find frontend/dist/stories -name "*.md" | wc -l
# Should show 40 stories

# If missing, rebuild
./build-vibe-kanban.sh
```

### Issue 3: Different Environment Variables

**Symptom:** Installer behaves differently with same binary

**Cause:** Environment variables differ

**Check:**
```bash
# Direct binary
./target/release/server
# Uses: Default config

# Installer
# Sets: PORT=${BACKEND_PORT}
# Check: What BACKEND_PORT is set to
```

### Issue 4: Working Directory Different

**Symptom:** Binary can't find resources

**Cause:** Running from different directory

**Check:**
```bash
# Direct binary
cd /path/to/vibe-kanban
./target/release/server  # CWD = vibe-kanban/

# Installer
cd /tmp/test
~/dist/install-bmad-vibe-kanban.sh  # CWD = /tmp/test/
```

## Verification Checklist

Before reporting "installer doesn't work":

- [ ] Ran `./build-vibe-kanban.sh` first
- [ ] Then ran `./build-installer.sh`
- [ ] Verified `local-build.sh` output shows "Using existing binaries"
- [ ] Checked timestamps of `frontend/dist/` and `target/release/server` match
- [ ] Tested direct binary works: `./target/release/server`
- [ ] Extracted installer to clean directory
- [ ] Checked browser console for JavaScript errors
- [ ] Verified stories exist in installation directory

## Debugging Tools

### Check Build Order

```bash
# Add this to local-build.sh for debugging
echo "DEBUG: Checking for existing binaries..."
if [ -f "${CARGO_TARGET_DIR}/release/server" ]; then
  echo "DEBUG: Found server at $(date -r ${CARGO_TARGET_DIR}/release/server)"
  echo "DEBUG: Skipping rebuild"
else
  echo "DEBUG: No existing server, will rebuild"
fi
```

### Compare Binaries

```bash
# Script to compare binaries
#!/bin/bash
DIRECT_MD5=$(md5 -q target/release/server)
PACKAGED_MD5=$(cd /tmp && unzip -qo ~/vibe-kanban/npx-cli/dist/macos-arm64/vibe-kanban.zip && md5 -q vibe-kanban)

if [ "$DIRECT_MD5" = "$PACKAGED_MD5" ]; then
  echo "✅ Binaries are identical"
else
  echo "❌ Binaries differ!"
  echo "Direct:   $DIRECT_MD5"
  echo "Packaged: $PACKAGED_MD5"
fi
```

### Extract and Test Installer Binary

```bash
# Extract binary from installer without running installer
cd /tmp/test-extract
mkdir -p .vibe-kanban
cd .vibe-kanban

# Extract from installer archive
tail -n+XXX ~/dist/install-bmad-vibe-kanban.sh | base64 -d | tar xz

# Find and run binary
./vibe-kanban
```

## Related Files

- `build-vibe-kanban.sh` - Builds binary with latest code
- `local-build.sh` - Packages binary (now skips rebuild if exists)
- `build-installer.sh` - Calls local-build.sh and creates installer
- `bmad-templates/scripts/build-installer.sh` - Creates self-extracting installer

## Last Updated

- **Date:** 2026-02-15
- **Commit:** 1dce7400
- **Issue:** Fixed local-build.sh rebuilding unnecessarily
- **Status:** ✅ Direct binary and installer now use identical code
