{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.services.suwayomi-server.enable {
    services.suwayomi-server = {
      package = pkgs.unstable.suwayomi-server;
      settings = {
        port = 8888;
      };
      openFirewall = lib.mkDefault config.services.media.openFirewall;
    };

    users.users.suwayomi.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];
  };
}
