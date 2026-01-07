#!/usr/bin/env bash

PACKAGE="opencode"

nix-update legacyPackages.x86_64-linux.$PACKAGE \
        --subpackage node_modules \
        --flake \
        --override-filename "$NH_FLAKE/packages/top-level/$PACKAGE/package.nix"
