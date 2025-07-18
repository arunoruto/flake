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

  systemd-boot.enable = lib.mkDefault true;
  grub.enable = lib.mkDefault false;

  boot = {
    loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;
      timeout = lib.mkDefault 0; # Hit F10 for a list of generations
    };
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    # plymouth.enable = true;
  };
}
