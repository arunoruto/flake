{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.bosflix.enable = lib.mkEnableOption "Enable bosflix services";

  config = lib.mkIf config.bosflix.enable {
    services = {
      prowlarr = {
        enable = true;
        package = pkgs.unstable.prowlarr;
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
