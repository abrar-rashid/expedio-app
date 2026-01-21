---
name: commit-changes
description: Stages all changes and creates a descriptive commit message based on the current git diff. Use when the user wants to commit all pending changes with an auto-generated message.
disable-model-invocation: true
allowed-tools: Bash
---

You are executing the `/commit-changes` skill. Follow these steps:

1. **Stage all changes**: Run `git add .` to stage all modified, deleted, and new files.

2. **Get the diff**: Run `git diff --staged` to see what will be committed.

3. **Analyze the changes**: Review the staged diff to understand:
   - What files were modified/added/deleted
   - The nature of changes (new feature, bug fix, refactoring, docs, etc.)
   - The overall purpose and impact

4. **Create a descriptive commit message**:
   - Use conventional commit format when appropriate (e.g., `feat:`, `fix:`, `refactor:`, etc.)
   - Write a clear, concise summary (50-72 characters) on the first line
   - If the changes are complex, add a blank line and then bullet points explaining key changes
   - Focus on the "why" and "what", not just the "how"
   - Ensure the message accurately reflects the changes

5. **Commit the changes**: Use a heredoc to properly format the commit message:
   ```bash
   git commit -m "$(cat <<'EOF'
   Your commit message here.

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
   EOF
   )"
   ```

6. **Confirm**: Run `git log -1` to show the created commit and confirm success.

**Important Notes**:
- NEVER skip git hooks (no `--no-verify` flag)
- If there are no changes to commit, inform the user
- If you detect potential secrets (.env files, credentials), warn the user before committing
- If the commit fails due to pre-commit hooks, fix the issues and create a NEW commit (never use `--amend`)
- Do NOT push unless explicitly requested by the user
