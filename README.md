# Mirza's Nix Config

<p align="center">
  <img src="docs/nixos-logo-cloudy.webp" width="300" alt="NixOS logo">
</p>

NixOS, nix-darwin, and Home Manager configurations managed as a single flake.

## Quick Start

```sh
git clone https://github.com/arunoruto/flake ~/.config/flake
```

### NixOS

```sh
sudo nixos-rebuild switch --flake ~/.config/flake#<device-name> --accept-flake-config
```

### Darwin

```sh
sudo nix run nix-darwin/nix-darwin-<version>#darwin-rebuild -- switch
```

Replace `<version>` with the nix-darwin release (e.g., `25.11`).

### Home Manager

```sh
home-manager switch --flake ~/.config/flake#<username> --accept-flake-config
```

#### Standalone (non-NixOS)

```sh
nix --experimental-features 'nix-command flakes' --accept-flake-config run nixpkgs#home-manager -- switch --flake ~/.config/flake#<username>
```

> Some shells (e.g. zsh) require quoting the flake argument: `--flake './#<username>'`

## Documentation

Full documentation site: `nix build .#docs` or `mdbook serve` in the repo root.
