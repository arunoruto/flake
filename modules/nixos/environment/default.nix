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
    ./latex.nix
    ./ld.nix
    ./programming.nix
    ./python.nix

    ./amd
    ./intel.nix
  ];

  cachix.enable = lib.mkDefault false;
  gui.enable = lib.mkDefault true;
  latex.enable = lib.mkDefault false;

  amd.enable = lib.mkDefault false;
  intel.enable = lib.mkDefault false;
}
