# Fork Restoration - 2026-02-16

## Issue

The repository was accidentally polluted with upstream commits from the BloopAI/vibe-kanban main branch (versions 0.1.5 through 0.1.9+) that were never intended to be included in this fork.

## Root Cause

After initial clone from upstream, a `git pull` was executed on main branch **before** creating the work branch `fix/move-to-old-ui`. This brought in ~90 commits (versions 0.1.5-0.1.9) from upstream that included:
- New onboarding flow with LandingPage
- Remote/cloud features
- Features incompatible with local-only v0.1.4 architecture

When `fix/move-to-old-ui` (correctly based on v0.1.4) was merged back to main, the upstream pollution remained.

## Resolution

Reset main branch to `fix/move-to-old-ui` which contains:
- Clean fork from Vibe Kanban v0.1.4 (commit 41d51377, tag: v0.1.4-20260205093507)
- All BMAD integration work
- No upstream pollution

```bash
git reset --hard fix/move-to-old-ui
git push --force-with-lease origin main
```

## Version Confirmation

- **Server version**: 0.1.4 (crates/server/Cargo.toml)
- **Base commit**: 41d51377 (chore: bump version to 0.1.4)
- **BMAD commits**: 1605 commits total on fix/move-to-old-ui
- **Build status**: ✅ Functional (tested 2026-02-16)

## Upstream Isolation

This fork is now permanently isolated from BloopAI/vibe-kanban upstream:
- Remote points only to fabthefabulousfab/bmad-vibe-kanban
- No upstream remote configured
- **NEVER** pull from BloopAI/vibe-kanban

## Rationale for v0.1.4

v0.1.4 (tag: local-only-version) was chosen as the fork point because:
1. **Last fully local version** - No cloud/remote dependencies
2. **Data sovereignty** - Complete local operation
3. **Privacy-first** - No external API calls
4. **BMAD compatibility** - Local-first aligns with BMAD methodology

Subsequent versions (0.1.5+) introduced remote features and cloud dependencies incompatible with the local-first, privacy-focused architecture required for BMAD integration.

## Prevention

To prevent future pollution:
1. Never add BloopAI/vibe-kanban as a remote
2. Never pull/fetch from upstream
3. All development happens on this isolated fork
4. Document any exceptions in this file

## Verification

Current state verified:
- ✅ Version is 0.1.4
- ✅ Build completes successfully
- ✅ No upstream commits after 41d51377
- ✅ All BMAD integration intact
- ✅ Remote points to correct fork

Last verified: 2026-02-16
