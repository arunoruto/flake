{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.radarr.enable (
    (lib.arr.arrConfig "radarr" config pkgs.unstable) // { }
  );
}
