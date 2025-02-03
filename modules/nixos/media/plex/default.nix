{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    plex.enable = lib.mkEnableOption "Enable Plex on the host";
  };

  config = lib.mkIf config.plex.enable {
    services.plex = {
      enable = true;
      package = pkgs.unstable.plex;
    };
  };
}
