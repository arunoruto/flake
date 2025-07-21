{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.prowlarr.enable (
    (lib.arr.arrConfig "prowlarr" config pkgs.unstable) // { }
  );
}
