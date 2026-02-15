#!/usr/bin/env bash

nix-update legacyPackages.x86_64-linux.beszel \
        --subpackage webui \
        --flake \
        --override-filename "$NH_FLAKE/packages/top-level/beszel/package.nix"
