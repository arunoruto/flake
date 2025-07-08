{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.jellyfin.enable {
    services.jellyfin = {
      package = lib.mkDefault pkgs.unstable.jellyfin;
      openFirewall = lib.mkDefault config.services.media.openFirewall;
    };
  };
}
