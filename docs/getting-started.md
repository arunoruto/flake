# Getting Started

## Clone

```sh
git clone https://github.com/arunoruto/flake ~/.config/flake
```

The flake sets `NH_FLAKE` (used by [`nh`](./daily-usage.md)) to `~/.config/flake`
automatically. If you clone elsewhere, override it:

```sh
export NH_FLAKE=/path/to/flake
```

Most day-to-day commands are wrapped in the [`justfile`](./daily-usage.md) — run
`just --list` from the repo root to see them.

## NixOS

First-time install:

```sh
sudo nixos-rebuild switch --flake ~/.config/flake#<device-name> --accept-flake-config
```

After initial setup, use `nh` for convenience (see [Daily Usage](./daily-usage.md)):

```sh
nh os switch ~/.config/flake#<device-name>
```

## Darwin (macOS)

```sh
sudo nix run nix-darwin/nix-darwin-<version>#darwin-rebuild -- switch
```

Replace `<version>` with the nix-darwin release (e.g., `25.11`).

## Home Manager

### On NixOS

```sh
home-manager switch --flake ~/.config/flake#<username> --accept-flake-config
```

### Standalone (non-NixOS)

```sh
nix --experimental-features 'nix-command flakes' --accept-flake-config run nixpkgs#home-manager -- switch --flake ~/.config/flake#<username>
```

> Shells like zsh require quoting: `--flake './#<username>'`

## Directory layout

Your host config lives in `systems/<arch>/<host>/`. Home Manager profiles are in `homes/<username>/`. Add new ones following the existing patterns.
