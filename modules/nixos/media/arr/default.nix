{
  config,
  pkgs,
  lib,
  ...
}:
{
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
