{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./programming

    ./packages.nix
    ./cachix.nix
    ./fonts.nix
    ./latex.nix
    ./ld.nix
  ];

  cachix.enable = lib.mkDefault false;
  latex.enable = lib.mkDefault false;
  programming.enable = lib.mkDefault true;
}
