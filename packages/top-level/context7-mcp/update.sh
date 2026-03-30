#!/usr/bin/env bash

PACKAGE="context7-mcp"

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
        --use-update-script --flake \
        --override-filename "$NH_FLAKE/packages/custom/$PACKAGE/package.nix"
