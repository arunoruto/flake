# Everything steamos ships that is not the NixOS module: the two daemons the
# module can drive but nixpkgs does not package, and the Decky plugin scope.
#
# Takes a plain nixpkgs `pkgs` and returns an attrset shaped like what the
# overlay adds — so the same file backs `overlays.default`, the flake's
# `packages` output, and the parent repo's legacyPackages re-export.
{ pkgs }:
{
  steamos-manager = pkgs.callPackage ./steamos-manager/package.nix { };
  decky-loader = pkgs.callPackage ./decky-loader/package.nix { };

  # pkgs.deckyPlugins.*: buildDeckyPlugin plus one directory per packaged
  # plugin, auto-discovered. The steamos module's `decky-loader.plugins`
  # option consumes these, mix-and-matchable with store-installed plugins.
  deckyPlugins = pkgs.lib.makeScope pkgs.newScope (
    self:
    pkgs.lib.packagesFromDirectoryRecursive {
      inherit (self) callPackage newScope;
      directory = ./deckyPlugins;
    }
  );
}
