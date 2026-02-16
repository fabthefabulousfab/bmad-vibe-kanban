# Installer Binary Update Bug

## Date
2026-02-15 22:45

## Problem Statement

The installer does NOT update the vibe-kanban binary on subsequent runs. Once vibe-kanban is installed to `~/.bmad-vibe-kanban/bin/vibe-kanban`, it stays at that version forever, even when running a newer installer.

## Evidence

### Test Sequence

```bash
# 1. Build fresh binary
./build-vibe-kanban.sh
# Result: target/release/server built Feb 15 22:28
# MD5: 1fa3751e48f23775d2e763f078137ac2

# 2. Package and build installer
./build-installer.sh
# Result: dist/install-bmad-vibe-kanban.sh (55M)
# Packaged: npx-cli/dist/macos-arm64/vibe-kanban.zip Feb 15 22:30
# MD5 of packaged binary: 1fa3751e48f23775d2e763f078137ac2 ✓ MATCHES

# 3. Run installer
cd /tmp/test && ~/vibe-kanban/dist/install-bmad-vibe-kanban.sh --skip-deps
# Expected: Binary extracted to ~/.bmad-vibe-kanban/bin/vibe-kanban
# Actual: Binary NOT UPDATED

# 4. Check installed binary
ls -lah ~/.bmad-vibe-kanban/bin/vibe-kanban
# Result: Feb 12 15:08 (OLD!)
# MD5: 2037f1d452e2d7bf94215d6d632f8302 ✗ DIFFERENT

# 5. Verify packaged binary is correct
unzip -qo ~/vibe-kanban/npx-cli/dist/macos-arm64/vibe-kanban.zip
md5 vibe-kanban
# Result: 1fa3751e48f23775d2e763f078137ac2 ✓ CORRECT

# Conclusion: Installer contains correct binary but doesn't extract it
```

### Impact

**User Experience:**
- User builds latest code → Works when testing direct binary
- User builds installer → Installer contains OLD binary forever
- "Select Workflow" button shows different behavior:
  - Direct binary: ✓ Imports stories correctly
  - Installed binary: ✗ Shows shell script menu instead

## Root Cause

### Location
File: `bmad-templates/scripts/build-installer.sh`
Function: `extract_vibe_binary()`
Lines: 408-413

### Problematic Code

```bash
# Check if binary already extracted
local vibe_binary="${VIBE_BINARY_DIR}/vibe-kanban"
if [[ -x "$vibe_binary" ]]; then
    echo "$vibe_binary"
    return 0
fi
```

**Problem:**
1. Function checks if binary exists at `~/.bmad-vibe-kanban/bin/vibe-kanban`
2. If it exists, **immediately returns** without extracting new binary
3. This happens regardless of:
   - Binary version/date
   - Whether installer has newer binary
   - Whether `NEED_UPGRADE=1` is set

### Why VERSION Check Doesn't Help

The installer has version comparison logic (lines 500-539):

```bash
if [[ -f "VERSION" && -f "scripts/import-bmad-workflow.sh" && -d "_bmad" ]]; then
    source VERSION 2>/dev/null || true
    INSTALLED_VERSION="${BMAD_VIBE_KANBAN_VERSION:-unknown}"

    version_compare "$INSTALLER_VERSION" "$INSTALLED_VERSION"
    # Sets NEED_UPGRADE=1 if installer is newer
fi
```

**BUT:** This only compares VERSION file (templates/stories version), NOT the binary version!

The VERSION file tracks:
- `BMAD_VIBE_KANBAN_VERSION=0.1` - Templates/stories version
- `BMAD_VERSION=1.0` - BMAD framework version

It does NOT track:
- Vibe Kanban binary version
- Binary build date
- Binary MD5 hash

### Call Sites

`extract_vibe_binary()` is called in two places:

**1. Line 601 (ALREADY_INSTALLED path):**
```bash
if [[ "$ALREADY_INSTALLED" == "1" ]]; then
    if ! curl -s "http://127.0.0.1:${BACKEND_PORT}/api/health" &> /dev/null; then
        log_info "Starting Vibe Kanban..."
        VIBE_BINARY=$(extract_vibe_binary)  # ← Returns old binary!
        PORT=${BACKEND_PORT} nohup "$VIBE_BINARY" > /tmp/vibe-kanban-$$.log 2>&1 &
    fi
fi
```

**2. Line 829 (Fresh install path):**
```bash
VIBE_BINARY=$(extract_vibe_binary)
```

In **both cases**, if binary exists, old binary is used!

## Solution Options

### Option 1: Always Extract (Simplest)

Remove the early-return check entirely:

```bash
extract_vibe_binary() {
    local platform="$1"
    local vibe_binary="${VIBE_BINARY_DIR}/vibe-kanban"

    # Remove check - always extract:
    # OLD CODE (DELETE):
    # if [[ -x "$vibe_binary" ]]; then
    #     echo "$vibe_binary"
    #     return 0
    # fi

    mkdir -p "$VIBE_BINARY_DIR"

    # ... rest of extraction code ...
}
```

**Pros:**
- Guarantees fresh binary every install
- Simple, no version tracking needed

**Cons:**
- Extracts even when not needed
- Slightly slower (adds ~2 seconds)

### Option 2: Force Extract on Upgrade

Only skip extraction if version matches:

```bash
extract_vibe_binary() {
    local platform="$1"
    local vibe_binary="${VIBE_BINARY_DIR}/vibe-kanban"

    # NEW: Skip only if same version
    if [[ -x "$vibe_binary" && "$ALREADY_INSTALLED" == "1" ]]; then
        echo "$vibe_binary"
        return 0
    fi

    # OLD: if [[ -x "$vibe_binary" ]]; then

    mkdir -p "$VIBE_BINARY_DIR"

    # ... rest of extraction code ...
}
```

**Pros:**
- Faster for same-version reinstalls
- Still guarantees updates when needed

**Cons:**
- Relies on VERSION file accuracy
- VERSION doesn't track binary changes

### Option 3: Check Binary Timestamp/Hash

Store binary version in a separate file:

```bash
extract_vibe_binary() {
    local platform="$1"
    local vibe_binary="${VIBE_BINARY_DIR}/vibe-kanban"
    local vibe_version_file="${VIBE_BINARY_DIR}/.vibe-version"

    # Check if binary matches embedded version
    if [[ -x "$vibe_binary" && -f "$vibe_version_file" ]]; then
        local installed_hash=$(cat "$vibe_version_file")
        # Compare with embedded hash (would need to embed hash in installer)
        if [[ "$installed_hash" == "$EMBEDDED_BINARY_HASH" ]]; then
            echo "$vibe_binary"
            return 0
        fi
    fi

    # Extract binary...
    # After extraction, save hash:
    echo "$EMBEDDED_BINARY_HASH" > "$vibe_version_file"
}
```

**Pros:**
- Precise - only updates when binary actually changed
- Can skip extraction for identical rebuilds

**Cons:**
- Complex - requires embedding hash in installer
- Requires build process changes

## Recommended Fix

**Use Option 1 (Always Extract):**

1. Remove lines 408-413 from `extract_vibe_binary()`
2. Always extract binary to ensure it's current
3. Add `unzip -o` flag to force overwrite (already present on line 448)

**Minimal change:**

```diff
 extract_vibe_binary() {
     local platform="$1"
-
-    # Check if binary already extracted
-    local vibe_binary="${VIBE_BINARY_DIR}/vibe-kanban"
-    if [[ -x "$vibe_binary" ]]; then
-        echo "$vibe_binary"
-        return 0
-    fi
-
+    local vibe_binary="${VIBE_BINARY_DIR}/vibe-kanban"
+
     # Create binary directory
     mkdir -p "$VIBE_BINARY_DIR"
```

## Testing Plan

After fix:

```bash
# 1. Verify old binary exists
ls -lah ~/.bmad-vibe-kanban/bin/vibe-kanban
md5 ~/.bmad-vibe-kanban/bin/vibe-kanban
# Should show: Feb 12 15:08, MD5: 2037f1d452e2d7bf94215d6d632f8302

# 2. Run new installer
cd /tmp/test && ~/vibe-kanban/dist/install-bmad-vibe-kanban.sh --skip-deps

# 3. Verify binary was updated
ls -lah ~/.bmad-vibe-kanban/bin/vibe-kanban
md5 ~/.bmad-vibe-kanban/bin/vibe-kanban
# Should show: Feb 15 (current date), MD5: 1fa3751e48f23775d2e763f078137ac2

# 4. Test functionality
# - Open http://127.0.0.1:3001
# - Click orange '+' button
# - Verify "Select Workflow" shows story list (not shell menu)
```

## Related Files

- `bmad-templates/scripts/build-installer.sh` - Contains buggy `extract_vibe_binary()`
- `build-installer.sh` - Calls bmad-templates build script
- `local-build.sh` - Packages binaries (works correctly)
- `docs/INSTALLER-VS-DIRECT-BINARY.md` - Documents binary packaging flow
- `docs/INSTALLER-BUILD-FLOW.md` - Documents complete build process

## Status

- **Discovered:** 2026-02-15 22:45
- **Status:** 🔴 Not Fixed
- **Priority:** P0 - Critical (installer doesn't work)
- **Fix Required:** Remove early-return check in `extract_vibe_binary()`
