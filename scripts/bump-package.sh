#!/usr/bin/env bash
# Bump a custom package with nix-update.
# Usage: scripts/bump-package.sh packages/{custom,top-level}/<pkg>[/package.nix] [extra nix-update flags]
set -euo pipefail

# Resolve the flake root from this script's location so the script works
# regardless of the current directory or whether NH_FLAKE is set.
FLAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1. Parse the input path
if [ -z "${1:-}" ]; then
    echo "Error: Please provide a path to the package."
    echo "Usage: $0 packages/custom/beszel[/package.nix]"
    exit 1
fi

INPUT_PATH="$1"

# 2. Normalize path: if it doesn't end with .nix, append /package.nix
if [[ "$INPUT_PATH" != *.nix ]]; then
    INPUT_PATH="${INPUT_PATH%/}/package.nix"
fi

if [ ! -f "$FLAKE_ROOT/$INPUT_PATH" ]; then
    echo "Error: File not found at $FLAKE_ROOT/$INPUT_PATH"
    exit 1
fi

# 3. Extract the package name (the directory containing package.nix)
PACKAGE_DIR=$(dirname "$INPUT_PATH")
PACKAGE=$(basename "$PACKAGE_DIR")

# 4. Determine category and attribute path based on the folder structure
if [[ "$INPUT_PATH" == *"packages/custom/"* ]]; then
    ATTR_PATH="custom.$PACKAGE"
elif [[ "$INPUT_PATH" == *"packages/top-level/"* ]]; then
    ATTR_PATH="$PACKAGE"
elif [[ "$INPUT_PATH" == *"steamos/packages/deckyPlugins/"* ]]; then
    ATTR_PATH="deckyPlugins.$PACKAGE"
elif [[ "$INPUT_PATH" == *"steamos/packages/"* ]]; then
    ATTR_PATH="$PACKAGE"
else
    echo "Error: Unrecognized package location in path: $INPUT_PATH"
    echo "Path must contain 'packages/custom/', 'packages/top-level/' or 'steamos/packages/'"
    exit 1
fi

# 5. Detect platform
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS-$ARCH" in
Darwin-arm64 | Darwin-aarch64)
        PLATFORM="aarch64-darwin"
        ;;
Darwin-x86_64)
        PLATFORM="x86_64-darwin"
        ;;
Linux-aarch64 | Linux-arm64)
        PLATFORM="aarch64-linux"
        ;;
*)
        PLATFORM="x86_64-linux"
        ;;
esac

PREFIX="legacyPackages.$PLATFORM.$ATTR_PATH"
echo "Target Prefix: $PREFIX"
echo "Target File: $FLAKE_ROOT/$INPUT_PATH"

# 6. Fetch update args
RAW_JSON=$(nix eval "$FLAKE_ROOT#$PREFIX.passthru.updateScript" --json)
readarray -t UPDATE_ARGS < <(echo "$RAW_JSON" | nix run nixpkgs#jq -- -r '.[1:][]')

# 7. Shift the first argument (the path) so $@ only contains extra flags
shift

# 8. Run nix-update
nix-update "$PREFIX" \
        --flake \
        "${UPDATE_ARGS[@]}" \
        --override-filename "$FLAKE_ROOT/$INPUT_PATH" \
        "$@"
