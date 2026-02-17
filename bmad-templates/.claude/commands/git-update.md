---
name: 'git-update'
description: 'Automate git add, commit and push workflow'
---

You are executing the git-update command to automate the git add, commit, and push workflow.

Follow these steps exactly:

## Step 1: Check Git Status

Run `git status` to see what files have been modified, added, or deleted.

## Step 2: Stage Changes

Run `git add .` to stage all changes, or ask the user which specific files they want to stage if they prefer selective staging.

## Step 3: Create Commit

1. Run `git diff --cached` to review staged changes
2. Analyze the changes to create a meaningful commit message following conventional commits format:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `refactor:` for code refactoring
   - `docs:` for documentation changes
   - `test:` for test additions or modifications
   - `chore:` for maintenance tasks

3. Create the commit with a descriptive message using:
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>: <description>

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
   EOF
   )"
   ```

## Step 4: Merge into Main and Push

The project uses a local merge workflow (no PRs). After committing on the feature branch, merge into main and push.

### 4a: Detect worktree context

Run `git worktree list` to check if you are in a worktree.

- **If in a worktree** (current directory is NOT the main worktree): the `main` branch is locked by the primary worktree and cannot be checked out here. Identify the primary worktree path from `git worktree list` (the one with `main` checked out).
- **If in the primary repo** (not a worktree, or main worktree): you can checkout main directly.

### 4b: Push feature branch to origin

```bash
git push -u origin <branch-name>
```

### 4c: Merge into main

**From a worktree** (main is checked out elsewhere at `<primary-worktree-path>`):
```bash
git -C <primary-worktree-path> pull origin main
git -C <primary-worktree-path> merge <branch-name>
git -C <primary-worktree-path> push origin main
```

**From the primary repo** (main can be checked out directly):
```bash
git checkout main
git pull origin main
git merge <branch-name>
git push origin main
```

## Step 5: Confirmation

Display a summary of:
- Number of files changed
- Commit message used
- Feature branch name
- Whether merge into main was done from worktree or primary repo
- Remote push status for both feature branch and main

## Important Notes

- Always check git status first to avoid committing unwanted files
- Never commit sensitive files (.env, credentials, etc.)
- Ensure all tests pass before pushing (if applicable)
- Follow the conventional commits format for consistency
- Ask for confirmation before pushing if there are many changes
- When in a worktree, always use `git -C <primary-path>` to operate on main
- Never force-checkout main in a worktree -- it will fail because main is locked by the primary worktree
