#!/usr/bin/env bash

PACKAGE="opencode"

# Detect platform
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS-$ARCH" in
    Darwin-arm64|Darwin-aarch64)
        PLATFORM="aarch64-darwin"
        ;;
    Darwin-x86_64)
        PLATFORM="x86_64-darwin"
        ;;
    Linux-aarch64|Linux-arm64)
        PLATFORM="aarch64-linux"
        ;;
    *)
        PLATFORM="x86_64-linux"
        ;;
esac

# BRANCH="master"
# FILES=(
#         "relax-bun-version-check.patch"
#         "remove-special-and-windows-build-targets.patch"
# )

# for FILE in "${FILES[@]}"; do
#         wget "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/$BRANCH/pkgs/by-name/op/opencode/$FILE" -O "$NH_FLAKE/packages/top-level/$PACKAGE/$FILE"
# done

nix-update legacyPackages.custom.$PLATFORM.$PACKAGE \
        --subpackage node_modules \
        --flake \
        --version-regex "v(.*)" \
        --override-filename "$NH_FLAKE/packages/custom/$PACKAGE/package.nix"
