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

## Step 4: Push to Remote

1. Check if the current branch has a remote tracking branch
2. If yes, run `git push`
3. If no, run `git push -u origin <branch-name>`

## Step 5: Confirmation

Display a summary of:
- Number of files changed
- Commit message used
- Branch pushed to
- Remote repository status

## Important Notes

- Always check git status first to avoid committing unwanted files
- Never commit sensitive files (.env, credentials, etc.)
- Ensure all tests pass before pushing (if applicable)
- Follow the conventional commits format for consistency
- Ask for confirmation before pushing if there are many changes
