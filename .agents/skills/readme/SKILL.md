---
name: readme
description: Write or rewrite the project's README.md in the Best-README-Template layout
# Manual only: run via /readme, never picked by the model on its own.
disable-model-invocation: true
metadata:
  opencode/slash: "true"
  opencode/autoinvoke: "false"
---

## Purpose and scope

- Produce READMEs in the structure of
  [Best-README-Template](https://github.com/othneildrew/Best-README-Template),
  filled with facts taken from the project itself.
- Applies to new READMEs and to rewrites of existing ones. For a small edit
  to one section of an existing README, keep its current layout instead.

## Instructions

1. Read the template

   Read `assets/template.md` (next to this file) in full before writing.
   It is the upstream `BLANK_README.md`; the README follows its section
   order and markup.

2. Gather facts from the repository

   Do not guess anything that can be looked up:

   - Owner, repo name and host: `git remote get-url origin`.
   - Default branch: `git symbolic-ref refs/remotes/origin/HEAD`, else the
     current branch.
   - License: the actual file name (`LICENSE`, `LICENSE.md`, `LICENSE.txt`,
     ...) and its SPDX identifier.
   - Stack: manifests such as `flake.nix`, `Cargo.toml`, `pyproject.toml`,
     `package.json`, `go.mod`.
   - Build, run and install commands: `justfile`, `Makefile`, `flake.nix`
     apps/packages, package scripts, CI workflows.
   - Assets: whether a logo or screenshot exists in the repo.
   - Existing README: every real fact in it (install steps, usage, credits,
     links) must survive the rewrite.

3. Fill the template

   - Keep the template's skeleton: the `readme-top` anchor, the centered
     header block, the `<details>` table of contents, the
     `back to top` links after each section, and all link and badge
     definitions collected at the bottom as reference-style links.
   - Replace every placeholder (`github_username`, `repo_name`,
     `project_title`, `project_description`, `project_license`, ...) with
     real values.
   - Point `license-url` at the real default branch and license file; the
     template hard-codes `blob/master/LICENSE.txt`.
   - **Built With**: one shields.io badge per major technology actually
     used (`https://img.shields.io/badge/<Name>-<hex>?style=for-the-badge&logo=<simpleicons-slug>&logoColor=white`).
     Remove the template's example frameworks.
   - **Getting Started**: the project's real prerequisites and install
     method. For a flake, show the Nix route (`nix run`, `nix profile
     install`, or using it as a flake input) alongside any other one.
   - **Usage**: real commands or code taken from the project, not prose
     about what usage could look like.

4. Remove what does not apply

   - Delete the template's own comments (the "Thanks for checking out the
     Best-README-Template" block and the reference-link explanation) and
     all of its instructional text.
   - Drop sections with no real content (Roadmap, Acknowledgments, Contact,
     Top contributors, screenshot, logo, demo link, ...). When a section
     goes, also remove its table-of-contents entry and every reference
     link that is no longer used.
   - The repository badges (contributors, forks, stars, issues, license)
     and contrib.rocks only work on GitHub. For other hosts, drop them or
     use that host's equivalents.

5. Do not invent

   - No made-up features, roadmap items, demo URLs, docs sites, or
     screenshots.
   - No personal contact data (email, social handles, LinkedIn) unless the
     user provided it or it is already in the existing README. Leave the
     Contact section out instead, keeping only the project link if wanted.
   - When something important cannot be determined (for example, what the
     project is for), ask rather than filling in plausible-sounding text.

6. Check before finishing

   Search the written README for leftover placeholders and remove or
   replace every hit:

   ```sh
   grep -nE 'github_username|repo_name|project_title|project_description|project_license|twitter_handle|linkedin_username|email_client|example\.com|\[\]\(\)|ENTER YOUR API' README.md
   ```

   Also confirm that every reference link used in the body is defined at
   the bottom, every definition is used, and every table-of-contents anchor
   matches a heading.

## Source

`assets/template.md` is `BLANK_README.md` from
othneildrew/Best-README-Template at commit `fc444eb7`, released under the
Unlicense (public domain). Trailing whitespace was stripped; otherwise it is
unchanged.
