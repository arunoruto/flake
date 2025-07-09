{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.plex.enable {
    services.plex =
      let
        cfg = config.services.media;
      in
      {
        package = lib.mkDefault pkgs.unstable.plex;
        dataDir = lib.mkDefault "${cfg.dataDir}/plex";
        openFirewall = lib.mkDefault cfg.openFirewall;
      };

    users.users.plex.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];
  };
}
