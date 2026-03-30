#!/usr/bin/env bash

PACKAGE="beads"

# Detect platform
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

nix-update legacyPackages.$PLATFORM.$PACKAGE \
        --flake \
        --version-regex "v(.*)" \
        --override-filename "$NH_FLAKE/packages/top-level/$PACKAGE/package.nix" \
        "$@"
# --override-filename "/Users/mirza/.config/flake/packages/top-level/$PACKAGE/package.nix"
