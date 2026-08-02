set shell := ["bash", "-euo", "pipefail", "-c"]

host := `hostname -s`

# Show available recipes
default:
    @just --list

# ── system ──────────────────────────────────────────────────────────

# Build and activate this (or another) host's NixOS config
[linux]
switch target=host:
    nh os switch . -H {{ target }}

# Build this host's config and make it the boot default (activate on reboot)
[linux]
boot target=host:
    nh os boot . -H {{ target }}

# Build and activate this Mac's nix-darwin config
[macos]
switch target=host:
    ulimit -n 4096
    nh darwin switch . -H {{ target }}

# Build and activate a user's home-manager config
home user=env_var("USER"):
    nh home switch . -c {{ user }}

# ── fleet (colmena; available on management-tagged hosts) ───────────

# Deploy hosts with colmena, e.g. `just deploy --on madara`
deploy *args:
    colmena apply {{ args }}

# Deploy all hosts carrying a tag, e.g. `just deploy-tag nas`
deploy-tag tag *args:
    colmena apply --on @{{ tag }} {{ args }}

# ── updates ─────────────────────────────────────────────────────────

# Update flake inputs (all, or the named ones)
update *inputs:
    nix flake update {{ inputs }}

# Bump a custom package with nix-update, e.g. `just bump packages/top-level/trmnl`
bump pkg *flags:
    ./scripts/bump-package.sh {{ pkg }} {{ flags }}

# ── docs ────────────────────────────────────────────────────────────

# Regenerate the devix option reference into docs/devix/reference (gitignored)
docs-reference:
    #!/usr/bin/env bash
    set -euo pipefail
    out=$(nix build --no-link --print-out-paths .#docs-devix-reference)
    mkdir -p docs/devix/reference
    install -m644 "$out"/*.md docs/devix/reference/
    echo "regenerated docs/devix/reference from modules/devix"

# Serve the mdBook docs locally with live reload
docs: docs-reference
    nix run nixpkgs#mdbook -- serve docs --open

# Build the docs like CI does
docs-build:
    nix build .#docs

# ── iso ─────────────────────────────────────────────────────────────

# Build the installer ISO (+ checksums) for a host, e.g. `just iso shinji`
[linux]
iso target:
    nix build .#iso-{{ target }} -o result-iso-{{ target }}

# ── secrets ─────────────────────────────────────────────────────────

# Edit the encrypted secrets file
secrets:
    sops secrets/secrets.yaml

# Re-encrypt secrets after changing recipients in secrets/.sops.yaml
secrets-rekey:
    sops updatekeys secrets/secrets.yaml

# ── hygiene ─────────────────────────────────────────────────────────

# Format all nix files
fmt:
    nix fmt

# Run flake checks (formatting hook, package rules)
check:
    nix flake check --accept-flake-config

# Garbage-collect old generations and store paths
clean:
    nh clean all

# Remove nix-darwin user launchd agents left behind by an earlier generation
[macos]
prune-agents *flags:
    ./scripts/prune-user-agents.sh {{ flags }}

# Evaluate every nixos/darwin/home configuration; prints one drvPath per line
eval-all:
    #!/usr/bin/env bash
    set -uo pipefail
    names() { nix eval ".#$1" --apply 'cs: builtins.concatStringsSep " " (builtins.attrNames cs)' --raw; }
    for kind in nixosConfigurations darwinConfigurations; do
      for h in $(names "$kind"); do
        drv=$(nix eval ".#$kind.\"$h\".config.system.build.toplevel.drvPath" --raw 2>/dev/null) || drv="EVAL-FAILED"
        echo "$kind.$h $drv"
      done
    done
    for u in $(names homeConfigurations); do
      drv=$(nix eval ".#homeConfigurations.\"$u\".activationPackage.drvPath" --raw 2>/dev/null) || drv="EVAL-FAILED"
      echo "homeConfigurations.$u $drv"
    done
