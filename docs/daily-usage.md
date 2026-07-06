# Daily Usage

## Nix Helper (`nh`)

[`nh`](https://github.com/viperML/nh) is a convenience wrapper around common Nix operations.

With `FLAKE` set in your environment:

```sh
nh os switch      # Update NixOS
nh home switch    # Update Home Manager
nh clean all      # Garbage collection
```

Without `FLAKE`:

```sh
nh os switch ~/.config/flake#<device-name>
nh home switch ~/.config/flake#<username>
```

Set `FLAKE` via `environment.sessionVariables.FLAKE` in your system config.

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
nix develop .#go
nix develop .#python
nix develop .#nix   # includes statix, deadnix, nixfmt
```
