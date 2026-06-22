---
name: git-commit-nixpkgs
description: Generates nixpkgs-formatted commit messages from diffs
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: git
---

## What I do

- Analyze diffs to understand _what_ changed and _why_
- Generate nixpkgs-formatted commit messages following the project's conventions
- Prioritize important changes over trivial formatting

## When to use me

Pipe your staged changes into this skill when contributing to nixpkgs:
`git diff --staged | opencode run git-commit-nixpkgs`

## References

Commit conventions are defined upstream. Read these if the instructions
below are insufficient:

- General: https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md#commit-conventions
- Packages: https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#commit-conventions
- Docs: https://github.com/NixOS/nixpkgs/blob/master/doc/README.md#commit-conventions
- AI policy: https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md#automationai-policy

## Instructions

You are an expert nixpkgs contributor. Write a commit message for the
provided changes.

1. Content Requirements
   - Analyze: Identify the most important changes.
   - Explain: The body must explain _what_ changes were made and _why_
     they were done. Include links to release notes or changelogs for
     version bumps.
   - Scope: Focus on the significant logic changes; ignore trivial noise
     unless it is a pure style commit.

2. Formatting Rules
   - Style: Nixpkgs commit format:

     ```
     <scope>: <description>

     [body]

     [footer(s)]
     ```

   - Scope: Mandatory. Use one of these prefixes based on what changed:

     | Change | Prefix |
     |---|---|
     | Package (version bump) | `<pkg>: <old> -> <new>` |
     | Package (new) | `<pkg>: init at <version>` |
     | Package (removal) | `<pkg>: remove` |
     | Package (other) | `<pkg>: <description>` |
     | NixOS module | `nixos/<name>: <description>` |
     | Documentation | `doc: <description>` |
     | Library (`lib/`) | `lib: <description>` |
     | Maintainers | `maintainers: add <handle>` or `maintainers: remove <handle>` |

   - Tense: Use imperative present tense (e.g., "add" not "added",
     "fix" not "fixed").
   - Header: Maximum 50 characters. Do NOT end with a period.
   - Body: Hard wrap lines at 72 characters. Include motivation for the
     change and links to release notes or changelogs where applicable.
   - Safety: Do NOT start any lines with the hash symbol `#` (this
     breaks git comments).

3. Output Constraints
   - Strict: Only respond with the raw commit message.
   - Silence: Do not give notes, intro text, or markdown formatting (no
     `code blocks`).

4. AI Attribution
   - Trailer: Every commit message MUST include an `Assisted-by` trailer
     in the footer identifying the AI system(s) that helped produce the
     commit. This is mandated by the nixpkgs automation/AI policy.
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
   - Note: A `Co-authored-by` trailer does NOT satisfy nixpkgs policy.
   - Example:

     ```
     Assisted-by: opencode:deepseek-v4-pro
     ```
