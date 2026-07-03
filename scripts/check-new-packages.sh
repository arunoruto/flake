#!/usr/bin/env bash
# Newly added packages/**/package.nix files must opt into
# __structuredAttrs and strictDeps. Existing packages predate this
# convention and are intentionally left alone.
set -euo pipefail

missing=0

for file in "$@"; do
    if ! git diff --cached --name-only --diff-filter=A -- "$file" | grep -qx "$file"; then
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
