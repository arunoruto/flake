#!/usr/bin/env bash

PACKAGE="beads"

# nix-update legacyPackages.x86_64-linux.$PACKAGE \
nix-update legacyPackages.aarch64-darwin.$PACKAGE \
        --flake \
        --version-regex "v(.*)" \
        --override-filename "/Users/mirza/.config/flake/packages/top-level/$PACKAGE/package.nix"
        # --override-filename "$NH_FLAKE/packages/top-level/$PACKAGE/package.nix"
