{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.steam.enable {
    programs = {
      steam = {
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall to share downloads locally with other devices
        extraCompatPackages = with pkgs.unstable; [ proton-ge-bin ];
      };
      gamescope.enable = true;
    };
  };
}
