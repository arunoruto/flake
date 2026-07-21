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
    ./media
    ./nas
    ./network
    ./security
    ./tuning
    ./virtualization

    ./github-runner.nix
    ./harmonia.nix
    ./ssh.nix
  ];

  services = {
    ai.enable = lib.mkDefault false;
    flatpak.enable = lib.mkDefault config.xdg.portal.enable;
    openssh.enable = lib.mkDefault true;
  };
}
