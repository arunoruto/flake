{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.services.sabnzbd.enable {
    services.sabnzbd = {
    };

    users.users.sabnzbd.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];

  };
}
