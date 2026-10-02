

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
sudo nixos-rebuild switch --accept-flake-config --flake ~/.config/flake#<device-name>
```

### Darwin

```sh
sudo nix run nix-darwin/nix-darwin-<version>#darwin-rebuild -- switch --flake ~/.config/flake#<device-name>
```

Replace `<version>` with the nix-darwin release (e.g., `25.11`) and `<device-name>` with your macOS host.

### Home Manager

```sh
home-manager switch --flake ~/.config/flake#<username> --accept-flake-config
```

#### Standalone (non-NixOS)

```sh
nix --experimental-features 'nix-command flakes' --accept-flake-config run nixpkgs#home-manager -- switch --flake ~/.config/flake#<username>
```

> Some shells (e.g. zsh) require quoting the flake argument: `--flake './#<username>'`

## Common tasks

Day-to-day commands are wrapped in a `justfile` (run inside `nix develop .#nix`,
which provides `just`):

```sh
just              # list all recipes
just switch       # build + activate this host
just update       # update flake inputs
just check        # nix flake check
just docs         # serve the docs locally
```

## Documentation

Full documentation site: `nix build .#docs`, or `mdbook serve docs` for a live
preview. Start with [Architecture](docs/architecture.md) for a map of the repo.
