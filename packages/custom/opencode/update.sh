#!/usr/bin/env bash

# nix-update legacyPackages.custom.$PLATFORM.$PACKAGE \
#         --subpackage node_modules \
#         --flake \
#         --version-regex "v(.*)" \
#         --override-filename "$NH_FLAKE/packages/custom/$PACKAGE/package.nix"

PACKAGE="opencode"

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

PREFIX="legacyPackages.$PLATFORM.custom.$PACKAGE"
echo $PREFIX

RAW_JSON=$(nix eval "$NH_FLAKE#$PREFIX.passthru.updateScript" --json)
readarray -t UPDATE_ARGS < <(echo "$RAW_JSON" | nix run nixpkgs#jq -- -r '.[1:][]')

nix-update $PREFIX \
        --flake \
        "${UPDATE_ARGS[@]}" \
        --version-regex "v(.*)" \
        --override-filename "$NH_FLAKE/packages/custom/$PACKAGE/package.nix"
