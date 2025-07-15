{
  config,
  lib,
  ...
}:
{
  imports = [
    ./docker
    ./hardware
    ./input
    ./media
    ./nas
    ./network
    ./tuning

    ./ai.nix
    ./davmail.nix
    ./github-runner.nix
    ./flatpak.nix
    ./ssh.nix
  ];

  nas.enable = lib.mkDefault false;

  ai.enable = lib.mkDefault false;
  davmail.enable = lib.mkDefault false;
  flatpak.enable = lib.mkDefault config.xdg.portal.enable;
  ssh.enable = lib.mkDefault true;
}
