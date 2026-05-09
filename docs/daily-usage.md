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

## Dev Shells

Available shells (see `shells/`):

```sh
nix develop .#go
nix develop .#python
nix develop .#nix   # includes statix, deadnix, nixfmt
```
