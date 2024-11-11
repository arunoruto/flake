{
  config,
  lib,
  ...
}:
{
  options = {
    steam.enable = lib.mkEnableOption "Enable Steam";
  };

  config = lib.mkIf config.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall to share downloads locally with other devices
    };
  };
}
