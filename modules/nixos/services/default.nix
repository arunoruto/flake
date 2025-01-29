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

    ./ai.nix
    ./davmail.nix
    ./github-runner.nix
    ./flatpak.nix
    ./ssh.nix
    ./tlp.nix
    ./ppd.nix
  ];

  nas.enable = lib.mkDefault false;

  ai.enable = lib.mkDefault false;
  davmail.enable = lib.mkDefault false;
  flatpak.enable = lib.mkDefault config.xdg.portal.enable;
  ssh.enable = lib.mkDefault true;
  tlp.enable = lib.mkDefault false;
  ppd.enable = lib.mkDefault false;
}
