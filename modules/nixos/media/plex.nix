{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.plex.enable {
    services.plex = {
      package = pkgs.unstable.plex;
    };
  };
}
