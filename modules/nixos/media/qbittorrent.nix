{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.services.qbittorrent.enable {
    services.qbittorrent = {
      webuiPort = 8081;
      # settings = {
      #   "Connection\Port\Range\Min" = 49160;
      #   "Connection\Port\Range\Max" = 49200;
      #   "WebUI\Port" = 8080;
      #   "WebUI\Username" = "admin";
      #   "WebUI\Password\_PBKDF2" = "PBKDF2:10000:16:5b8c3e1f4d3a2b1c4d5e6f7a8b9c0d1e:3f4e5d6c7b8a9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5";
      #   "Downloads\SavePath" = "/home/mirza/Downloads/torrents";
      #   "Preferences\Locale" = "en_US";
      #   "Preferences\StartPausedEnabled" = false;
    };

    users.users.qbittorrent.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];

  };
}
