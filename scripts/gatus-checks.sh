#!/usr/bin/env bash
# Collects every NixOS host's services.gatus.tailnetChecks into the file the
# monitoring host's Gatus reads (modules/nixos/services/gatus.nix). One nix
# process per host keeps memory at a single host's worth. CI runs this with
# every lock bump; run it by hand (`just gatus-checks`) after changing a check.
set -euo pipefail
cd "$(dirname "$0")/.."

out=modules/nixos/services/gatus-checks.json
mapfile -t hosts < <(
  nix eval --accept-flake-config --json .#nixosConfigurations --apply builtins.attrNames |
    jq -r '.[] | select(startswith("iso-") | not)'
)
for host in "${hosts[@]}"; do
  echo "$host" >&2
  nix eval --accept-flake-config --json ".#nixosConfigurations.$host.config.services.gatus.tailnetChecks"
done | jq -s 'add | sort_by(.group // "", .name, .host)' >"$out.tmp"
mv "$out.tmp" "$out"
