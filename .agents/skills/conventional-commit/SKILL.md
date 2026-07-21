---
name: conventional-commit
description: Generates conventional commit messages from diffs
---

## Purpose and scope

- Generate strictly formatted Conventional Commits from git diffs.
- Prioritize important logic changes over trivial formatting noise.
- Applies to both staged and unstaged diffs.

## When to use me

Provide a diff and this skill will generate a commit message for the changes.

## Instructions

You are an expert developer. Write a commit message for the provided changes.

1. Content Requirements
   - Analyze: Identify the most important changes.
   - Explain: The body must explain _what_ changes were made and _why_ they were done.
   - Scope: Focus on the significant logic changes; ignore trivial noise unless it is a pure style commit.

2. Formatting Rules
   - Style: Conventional Commits:

     ```
     <type>(<optional scope>): <description>

     [optional body]

     [optional footer(s)]
     ```

   - Prefix: Use a valid semantic prefix (feat, fix, chore, refactor, style, docs, perf, test, ci, build, revert).
   - Breaking changes: Append `!` after the type/scope (e.g., `feat!:` or `feat(api)!:`) and include `BREAKING CHANGE:` in the footer.
   - Tense: Use imperative present tense (e.g., "add" not "added", "fix" not "fixed").
   - Header: Maximum 50 characters.
   - Body: Hard wrap lines at 72 characters.
   - Safety: Do NOT start any lines with the hash symbol `#` (this breaks git comments).

3. Output Constraints
   - Strict: Only respond with the raw commit message.
   - Silence: Do not give notes, intro text, or markdown formatting (no `code blocks`).

4. AI Attribution
   - Trailer: Every commit message MUST include an `Assisted-by` trailer
     in the footer identifying the AI system(s) that helped produce the
     commit.
   - Format: Follow the Linux kernel convention for AI tool attribution:

     ```
     Assisted-by: <agent_name>:<model_version>
     ```

   - Agent Name: Use the name of this AI tool (e.g. "opencode",
     "claude", "copilot"). Infer this from your identity or system
     prompt metadata.
   - Model Version: Use the specific model identifier (e.g.
     "gpt-4o", "claude-3-opus", "deepseek-v4-pro"). Get this from
     your model name in the system environment.
   - Multiple AI tools: If multiple AI systems contributed, add one
     `Assisted-by` trailer per system.

## Request changes when

- The type is missing or not from the allowed list.
- The description is missing or uses past tense instead of imperative mood.
- The header exceeds 50 characters.
- Body lines are not wrapped at 72 characters.
- Any line starts with `#`.
- The description duplicates the type instead of describing the change.
- The body restates the description without adding context.

## Checklist

- [ ] Type is a valid conventional commit prefix.
- [ ] Description is in imperative present tense.
- [ ] Header is 50 characters or fewer.
- [ ] Body explains _what_ and _why_, not just _what_.
- [ ] Body lines are wrapped at 72 characters.
- [ ] No line starts with `#`.
- [ ] Breaking changes use `!` notation and `BREAKING CHANGE:` footer.
- [ ] Assisted-by trailer is present.

## Examples

### Simple

```
feat(auth): add password reset flow
```

### Complex

```
feat(api)!: switch to token-based authentication

Replace session cookies with JWT tokens for stateless auth.
Refresh tokens are stored in httpOnly cookies.

BREAKING CHANGE: all existing sessions are invalidated.
Clients must migrate to the new token flow.

Assisted-by: opencode:deepseek-v4-pro
```
