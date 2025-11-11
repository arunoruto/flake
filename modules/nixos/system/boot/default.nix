{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./grub.nix
    ./systemd-boot.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
      efi.canTouchEfiVariables = lib.mkDefault true;
      timeout = lib.mkDefault 0; # Hit F10 for a list of generations
    };
    kernelPackages = lib.mkOverride 1001 pkgs.linuxPackages_latest;
    # plymouth.enable = true;
  };
}
