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
      settings.server = {
        ip = "0.0.0.0";
        port = 8888;
        extensionRepos = [ "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json" ];
      };
      # openFirewall = lib.mkDefault config.services.media.openFirewall;
      openFirewall = true;
    };

    users.users.suwayomi.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];
  };
}
