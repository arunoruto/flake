{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.services.arr.enable = lib.mkEnableOption "Enable arr frameworks";

  config = lib.mkIf config.services.arr.enable {
    services = {
      radarr = {
        enable = lib.mkDefault true;
        package = lib.mkDefault pkgs.unstable.radarr;
        openFirewall = lib.mkDefault config.services.media.openFirewall;
      };
      sonarr = {
        enable = lib.mkDefault true;
        package = lib.mkDefault pkgs.unstable.sonarr;
        openFirewall = lib.mkDefault config.services.media.openFirewall;
      };
      bazarr = {
        enable = lib.mkDefault true;
        package = lib.mkDefault pkgs.unstable.bazarr;
        openFirewall = lib.mkDefault config.services.media.openFirewall;
      };
    };

    nixpkgs.config.permittedInsecurePackages = [
      "aspnetcore-runtime-6.0.36"
      "aspnetcore-runtime-wrapped-6.0.36"
      "dotnet-runtime-6.0.36"
      "dotnet-runtime-wrapped-6.0.36"
      "dotnet-sdk-6.0.428"
      "dotnet-sdk-wrapped-6.0.428"
    ];
  };
}
