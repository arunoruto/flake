# steamos.nix — boot a NixOS machine straight into Steam's Gaming Mode, with a
# switchable Desktop Mode, without the full Jovian stack. See docs/.
#
# This flake currently lives inside a larger configuration repository, which
# consumes it as a relative-path input with `inputs.nixpkgs.follows` — so the
# lock file here is irrelevant to that parent and deliberately not committed.
# The layout is already the standalone one: when the project graduates to its
# own repository, consumers only swap the input URL.
{
  description = "steamos.nix — a SteamOS-like Gaming Mode for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
        steamos = ./modules/nixos;
      };

      # Adds steamos-manager, decky-loader and the deckyPlugins scope to pkgs —
      # which is also how the module's package options find their defaults
      # (`pkgs.steamos-manager or null`, `pkgs.decky-loader or null`).
      overlays.default = final: _prev: import ./packages { pkgs = final; };

      packages = eachSystem (
        system:
        let
          steamosPackages = import ./packages { pkgs = nixpkgs.legacyPackages.${system}; };
        in
        {
          inherit (steamosPackages) steamos-manager decky-loader;
          inherit (steamosPackages.deckyPlugins) hltb-for-deck protondb-decky;
          docs-reference = nixpkgs.legacyPackages.${system}.callPackage ./packages/docs-reference.nix { };
        }
      );

      # Room to grow, reserved rather than stubbed: Gaming Mode is a system
      # concern, but per-user pieces (Decky plugin settings, per-game
      # environment) would land here as homeModules.default.
    };
}
