{
  lib,
  pkgs,
  ...
}:
{
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
    ./nvidia
  ];

  cachix.enable = lib.mkDefault false;
  gui.enable = lib.mkDefault true;
  latex.enable = lib.mkDefault false;
  programming.enable = lib.mkDefault true;

  amd.enable = lib.mkDefault false;
  intel.enable = lib.mkDefault false;
  nvidia.enable = lib.mkDefault false;

  environment = {
    # Enable shells
    # shells = with pkgs; [
    #   bash
    #   nushell
    #   zsh
    # ];
    # pathsToLink = [
    #   "/share/zsh"
    #   "/share/fish"
    # ];
  };
}
