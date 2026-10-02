#!/usr/bin/env bash
# Newly added packages/**/package.nix files must opt into
# __structuredAttrs and strictDeps. Existing packages predate this
# convention and are intentionally left alone.
set -euo pipefail

missing=0

# Diff the whole index, not per file: rename detection needs both sides in
# view, and a pathspec on the new path alone makes a moved package (say
# top-level/ -> custom/) look newly added.
added="$(git diff --cached --name-only --diff-filter=A -M)"

for file in "$@"; do
    if ! grep -qxF "$file" <<<"$added"; then
        continue
    fi

    for attr in __structuredAttrs strictDeps; do
        if ! grep -qE "^[[:space:]]*${attr}[[:space:]]*=[[:space:]]*true[[:space:]]*;" "$file"; then
            echo "error: $file: new package is missing \`${attr} = true;\`"
            missing=1
        fi
    done
done

exit "$missing"
