{
  lib,
  config,
  ...
}: {
  imports = [
    ./gui

    ./packages.nix
    ./cachix.nix
    ./fonts.nix
    ./ld.nix
    ./programming.nix
    ./python.nix

    ./amd.nix
    ./intel.nix
  ];

  cachix.enable = lib.mkDefault true;
  gui.enable = lib.mkDefault true;

  amd.enable = lib.mkDefault false;
  intel.enable = lib.mkDefault false;
}
