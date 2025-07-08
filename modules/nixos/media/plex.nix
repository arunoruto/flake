{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.plex.enable {
    services.plex = {
      package = lib.mkDefault pkgs.unstable.plex;
      openFirewall = lib.mkDefault config.services.media.openFirewall;
    };
  };
}
