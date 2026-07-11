# Daily Usage

## Task runner (`just`)

Common commands live in the repo's `justfile`. Run `just --list` to see them all
(`just` is available in the `nix develop .#nix` shell). The essentials:

```sh
just switch          # build + activate this host (NixOS or macOS)
just home            # build + activate your home-manager config (standalone)
just update          # update all flake inputs
just fmt             # format all nix files
just check           # nix flake check
just docs            # serve these docs locally
just iso <host>      # build an installer ISO (Linux)
just deploy-tag nas  # colmena-deploy every host tagged `nas`
just bump packages/top-level/<pkg>   # bump a custom package with nix-update
```

The recipes wrap `nh`, `nix`, `colmena`, and `sops` — read them in the `justfile`
to see the exact commands.

## Nix Helper (`nh`)

[`nh`](https://github.com/viperML/nh) is a convenience wrapper around common Nix
operations. The flake sets `NH_FLAKE` to `~/.config/flake`, so these work from
anywhere:

```sh
nh os switch      # Update NixOS
nh home switch    # Update Home Manager
nh clean all      # Garbage collection
```

To point at a different checkout, override `NH_FLAKE` or pass the flake path
explicitly:

```sh
nh os switch ~/.config/flake#<device-name>
nh home switch ~/.config/flake#<username>
```

## Clean-up

```sh
nix-collect-garbage --delete-older-than 30d
nh clean all
```

## Git Fetchers

When adding a package from a git source, you need the commit and the Nix hash.

```sh
nix run nixpkgs#nix-prefetch-git https://github.com/EliverLara/candy-icons
```

Alternatively, leave the `hash` field empty in your derivation, attempt a build, and copy the hash from the error message.

## Remote Builds

Use a more powerful machine (like `kuchiki`) to build heavy packages (e.g., Rust projects):

```sh
nix build --builders "ssh://mirza@kuchiki.sparrow-yo.ts.net x86_64-linux" \
  -L .#nixosConfigurations.sado.config.services.stump.package
```

### Prerequisites

The Nix daemon runs as `root`, so root needs SSH access to the remote machine:

```sh
# Run once to add kuchiki's host key to root's known_hosts
sudo ssh mirza@kuchiki.sparrow-yo.ts.net
```

After that, remote builds will work without further configuration.

### Options

- `--max-jobs 0` — disable local builds entirely, force everything to remote
- Multiple builders: `--builders "ssh://host1 ... ; ssh://host2 ..."`

## Dev Shells

Available shells (see `shells/`):

```sh
nix develop .#go        # Go toolchain
nix develop .#website   # Hugo, for the website
nix develop .#nix       # just + statix, deadnix, nixfmt (the repo dev shell)
```
