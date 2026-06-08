{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.sonarr.enable (
    (lib.arr.arrConfig "sonarr" config pkgs.unstable) // { }
  );
}
