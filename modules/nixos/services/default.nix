{
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware
    ./input
    ./media
    ./nas
    ./network

    ./davmail.nix
    ./flatpak.nix
    ./oneapi.nix
    ./ssh.nix
    ./tlp.nix
    ./ppd.nix
  ];

  nas.enable = lib.mkDefault false;

  davmail.enable = lib.mkDefault false;
  flatpak.enable = lib.mkDefault config.xdg.portal.enable;
  oneapi.enable = lib.mkDefault false;
  # oneapi.enable = lib.mkDefault true;
  ssh.enable = lib.mkDefault true;
  tlp.enable = lib.mkDefault false;
  ppd.enable = lib.mkDefault false;
}
