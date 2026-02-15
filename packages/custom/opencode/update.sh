#!/usr/bin/env bash

PACKAGE="opencode"

# BRANCH="master"
# FILES=(
#         "relax-bun-version-check.patch"
#         "remove-special-and-windows-build-targets.patch"
# )

# for FILE in "${FILES[@]}"; do
#         wget "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/$BRANCH/pkgs/by-name/op/opencode/$FILE" -O "$NH_FLAKE/packages/top-level/$PACKAGE/$FILE"
# done

nix-update legacyPackages.x86_64-linux.$PACKAGE \
        --subpackage node_modules \
        --flake \
        --version-regex "v(.*)" \
        --override-filename "$NH_FLAKE/packages/top-level/$PACKAGE/package.nix"
