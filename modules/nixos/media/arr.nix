{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    arr.enable = lib.mkEnableOption "Enable arr frameworks";
  };

  config = lib.mkIf config.arr.enable {
    services = {
      radarr = {
        enable = true;
        package = pkgs.unstable.radarr;
      };
      sonarr = {
        enable = true;
        package = pkgs.unstable.sonarr;
      };
      bazarr = {
        enable = true;
        # package = pkgs.unstable.bazarr;
      };
    };
  };
}
