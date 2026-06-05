{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.lidarr.enable (
    (lib.arr.arrConfig "lidarr" config pkgs.unstable) // { }
  );
}
