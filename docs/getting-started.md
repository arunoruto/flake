# Getting Started

## Clone

```sh
git clone https://github.com/arunoruto/flake ~/.config/flake
```

If you clone elsewhere, set the `FLAKE` environment variable:

```sh
export FLAKE=/path/to/flake
```

Commands throughout this guide assume `FLAKE` points to your flake directory.

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

Your host config lives in `systems/<arch>/<host>/`. Home Manager profiles are in `homes/<arch>/<username>/`. Add new ones following the existing patterns.
