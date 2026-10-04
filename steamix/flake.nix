# Steamix — boot a NixOS machine straight into Steam's Gaming Mode, with a
# switchable Desktop Mode, without the full Jovian stack. See docs/.
#
# This flake currently lives inside a larger configuration repository, which
# consumes it as a relative-path input with `inputs.nixpkgs.follows` — so the
# lock file here is irrelevant to that parent and deliberately not committed.
# The layout is already the standalone one: when the project graduates to its
# own repository, consumers only swap the input URL.
{
  description = "Steamix — a SteamOS-like Gaming Mode for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  # Steamix's binary cache, for anything built from this flake directly
  # (`nix build`, the VM tests). Nix ignores a flake's nixConfig when the flake
  # is an input, so machines importing the module get the same cache from
  # the `steamix.binaryCache.enable` option instead. The URL and key are
  # repeated in modules/nixos/default.nix; keep them in step.
  nixConfig = {
    extra-substituters = [ "https://steamix.cachix.org" ];
    extra-trusted-public-keys = [
      "steamix.cachix.org-1:RDiQCw/nTZL8BuFm4uZrKEnkCU0xJ+w7zwQ+IQBXan0="
    ];
  };

  outputs =
    { self, nixpkgs }:
    let
      # The session stack is x86_64 in practice (Steam), but nothing here is
      # arch-specific enough to hard-fail an aarch64 evaluation.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      eachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      nixosModules = {
        default = ./modules/nixos;
        steamix = ./modules/nixos;
      };

      # Adds steamos-manager, decky-loader and the deckyPlugins scope to pkgs —
      # which is also how the module's package options find their defaults
      # (`pkgs.steamos-manager or null`, `pkgs.decky-loader or null`).
      overlays.default = final: _prev: import ./packages { pkgs = final; };

      packages = eachSystem (
        system:
        let
          steamixPackages = import ./packages { pkgs = nixpkgs.legacyPackages.${system}; };
        in
        {
          inherit (steamixPackages) steamos-manager decky-loader;
          inherit (steamixPackages.deckyPlugins) hltb-for-deck protondb-decky;
          docs-reference = nixpkgs.legacyPackages.${system}.callPackage ./packages/docs-reference.nix { };
        }
      );

      # VM tests (see tests/default.nix). x86_64-linux only: Gaming Mode is
      # Steam, and Steam is x86_64.
      checks.x86_64-linux = import ./tests { pkgs = nixpkgs.legacyPackages.x86_64-linux; };

      # What CI pushes to steamix.cachix.org: what a Steamix machine would
      # otherwise compile itself, because cache.nixos.org does not have it.
      # The two daemons nixpkgs does not package, and the 32-bit gamescope
      # WSI layer, which the module installs by default (`wsi.package32`) and
      # Hydra does not build. The Decky plugins are left out: they are
      # release downloads, so caching them saves nothing.
      #
      # A cache only helps a machine that asks for the exact store path, so
      # CI builds this against the nixpkgs revisions it is pinned to; see
      # docs/binary-cache.md.
      legacyPackages.x86_64-linux.cache =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          steamixPackages = import ./packages { inherit pkgs; };
        in
        {
          inherit (steamixPackages) steamos-manager decky-loader;
          gamescope-wsi-32 = pkgs.pkgsi686Linux.gamescope-wsi;
        };

      # Room to grow, reserved rather than stubbed: Gaming Mode is a system
      # concern, but per-user pieces (Decky plugin settings, per-game
      # environment) would land here as homeModules.default.
    };
}
