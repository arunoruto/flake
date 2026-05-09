{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.services.sabnzbd.enable {
    services.sabnzbd = {
    };

    systemd.services.sabnzbd.serviceConfig.UMask = "0002";

    users.users.sabnzbd.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];
  };
}
