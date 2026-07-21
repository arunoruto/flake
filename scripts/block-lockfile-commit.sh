#!/usr/bin/env bash
# flake.lock is updated exclusively by the scheduled "Update Lockfile"
# GitHub Action, which pushes straight to main. A local commit here almost
# always means a stray `nix flake update` — drop it and `git pull` once the
# action has run. For the rare deliberate case (e.g. bumping one input to
# unblock a fix), set ALLOW_LOCKFILE_COMMIT=1.
#
# Only fire when flake.lock is actually staged: `nix flake check` builds this
# hook against a plain source copy with no git index, and `git diff --cached`
# fails there, so this exits clean instead of always blocking the build.
set -euo pipefail

if [ -n "${ALLOW_LOCKFILE_COMMIT:-}" ]; then
    exit 0
fi

if ! git diff --cached --name-only 2>/dev/null | grep -qx "flake.lock"; then
    exit 0
fi

echo "error: flake.lock is CI-managed (see .github/workflows/update.yaml) — commit blocked." >&2
echo "Run 'git pull' for the latest lock, or ALLOW_LOCKFILE_COMMIT=1 git commit ... to override." >&2
exit 1
