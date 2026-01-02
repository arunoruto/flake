#!/usr/bin/env bash

nix-update legacyPackages.x86_64-linux.context7 \
        --version-regex "@upstash/context7-mcp@(.*)" \
        --flake \
        --override-filename "$NH_FLAKE/packages/top-level/context7/package.nix"
