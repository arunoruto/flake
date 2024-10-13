{
  lib,
  config,
  ...
}: {
  imports = [
    ./gui
    ./programming

    ./packages.nix
    ./cachix.nix
    ./fonts.nix
    ./latex.nix
    ./ld.nix

    ./amd
    ./intel.nix
  ];

  cachix.enable = lib.mkDefault false;
  gui.enable = lib.mkDefault true;
  latex.enable = lib.mkDefault false;
  programming.enable = lib.mkDefault true;

  amd.enable = lib.mkDefault false;
  intel.enable = lib.mkDefault false;
}
