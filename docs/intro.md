# Introduction

<p align="center">
  <img src="nixos-logo-cloudy.webp" width="300" alt="NixOS logo">
</p>

This flake manages all Nix-based configurations — NixOS, nix-darwin, and Home Manager — from a single repository.

## What's inside

| Directory | Purpose |
|-----------|---------|
| `systems/` | NixOS and nix-darwin host configurations (one directory per host) |
| `homes/` | Home Manager user environments |
| `modules/` | Reusable NixOS, darwin, home-manager, and devix (dev-env) modules |
| `packages/` | Custom packages and overrides |
| `shells/` | Dev shells (`nix develop .#go`, `.#website`, `.#nix`) |
| `overlays/` | Nixpkgs overlays |
| `lib/` | Helper functions |
| `secrets/` | sops-encrypted secrets |
| `docs/` | This documentation (mdBook) |

See [Architecture](./architecture.md) for the full map, the tag system, and how
to add a host or user.

## Key technologies

- [Stylix](https://github.com/nix-community/stylix) — system-wide theming
- [Disko](https://github.com/nix-community/disko) — declarative disk partitioning
- [Colmena](https://github.com/zhaofengli/colmena) — stateless deployment
- [Devenv](https://devenv.sh/) — reproducible dev environments
- [SOPS-nix](https://github.com/Mic92/sops-nix) — secrets management
- [Lanzaboote](https://github.com/nix-community/lanzaboote) — Secure Boot
- [nixos-facter](https://github.com/numtide/nixos-facter) — hardware reports
