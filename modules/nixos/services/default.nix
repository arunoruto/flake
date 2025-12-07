{
  config,
  lib,
  ...
}:
{
  imports = [
    ./ai
    ./hardware
    ./home-assistant
    ./input
    ./media
    ./nas
    ./network
    ./security
    ./tuning
    ./virtualization

    ./davmail.nix
    ./github-runner.nix
    ./harmonia.nix
    ./ssh.nix
  ];

  nas.enable = lib.mkDefault false;

  davmail.enable = lib.mkDefault false;
  services = {
    ai.enable = lib.mkDefault false;
    flatpak.enable = lib.mkDefault config.xdg.portal.enable;
    openssh.enable = lib.mkDefault true;
  };
}
