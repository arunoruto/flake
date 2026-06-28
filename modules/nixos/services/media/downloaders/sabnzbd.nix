{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.services.sabnzbd.enable {
    services.sabnzbd = {
      configFile = lib.mkForce null;
    };

    systemd.services.sabnzbd.serviceConfig.UMask = "0002";

    users.users.sabnzbd.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];
  };
}
