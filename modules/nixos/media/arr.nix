{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.services.arr.enable = lib.mkEnableOption "Enable arr frameworks";

  config = lib.mkIf config.services.arr.enable {
    services =
      let
        cfg = config.services.media;
      in
      {
        radarr = {
          enable = lib.mkDefault true;
          package = lib.mkDefault pkgs.unstable.radarr;
          dataDir = lib.mkDefault "${cfg.dataDir}/radarr";
          openFirewall = lib.mkDefault cfg.openFirewall;
        };
        sonarr = {
          enable = lib.mkDefault true;
          package = lib.mkDefault pkgs.unstable.sonarr;
          dataDir = lib.mkDefault "${cfg.dataDir}/sonarr";
          openFirewall = lib.mkDefault cfg.openFirewall;
        };
        bazarr = {
          enable = lib.mkDefault true;
          package = lib.mkDefault pkgs.unstable.bazarr;
          # dataDir = lib.mkDefault "${cfg.dataDir}/bazarr";
          openFirewall = lib.mkDefault cfg.openFirewall;
        };
      };

    # nixpkgs.config.permittedInsecurePackages = [
    #   "aspnetcore-runtime-6.0.36"
    #   "aspnetcore-runtime-wrapped-6.0.36"
    #   "dotnet-runtime-6.0.36"
    #   "dotnet-runtime-wrapped-6.0.36"
    #   "dotnet-sdk-6.0.428"
    #   "dotnet-sdk-wrapped-6.0.428"
    # ];
  };
}
