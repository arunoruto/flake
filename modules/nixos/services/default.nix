{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware
    ./input
    ./media
    ./network

    ./davmail.nix
    ./flatpak.nix
    ./oneapi.nix
    ./secrets.nix
    ./ssh.nix
    ./tlp.nix
  ];

  davmail.enable = lib.mkDefault false;
  flatpak.enable = lib.mkDefault true;
  secrets.enable = lib.mkDefault true;
  oneapi.enable = lib.mkDefault false;
  # oneapi.enable = lib.mkDefault true;
  ssh.enable = lib.mkDefault true;
  tlp.enable = lib.mkDefault false;
  ppd.enable = lib.mkDefault false;
}
