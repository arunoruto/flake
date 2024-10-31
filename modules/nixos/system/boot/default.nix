{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./efi.nix
    ./grub.nix
    ./systemd-boot.nix
  ];

  efi.enable = lib.mkDefault true;
  systemd-boot.enable = lib.mkDefault true;
  grub.enable = lib.mkDefault false;

  boot = {
    loader.timeout = lib.mkDefault 0; # Hit F10 for a list of generations
    kernelPackages = pkgs.linuxPackages_latest;
    # plymouth.enable = true;
  };
}
