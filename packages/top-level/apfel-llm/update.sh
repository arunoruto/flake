#!/usr/bin/env bash

PACKAGE="apfel"

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

PREFIX="legacyPackages.$PLATFORM.$PACKAGE"
echo $PREFIX

RAW_JSON=$(nix eval "$NH_FLAKE#$PREFIX.passthru.updateScript" --json)
readarray -t UPDATE_ARGS < <(echo "$RAW_JSON" | nix run nixpkgs#jq -- -r '.[1:][]')

nix-update $PREFIX \
        --flake \
        "${UPDATE_ARGS[@]}" \
        --override-filename "$NH_FLAKE/packages/top-level/$PACKAGE/package.nix"
