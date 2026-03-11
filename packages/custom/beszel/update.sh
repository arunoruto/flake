#!/usr/bin/env bash

PACKAGE="beszel"

nix-update legacyPackages.x86_64-linux.custom.$PACKAGE \
        --subpackage webui \
        --flake \
        --version-regex "v(.*)" \
        --override-filename "$NH_FLAKE/packages/custom/$PACKAGE/package.nix"
