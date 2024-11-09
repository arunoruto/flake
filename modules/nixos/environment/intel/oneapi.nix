{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.oneapi.enable = lib.mkEnableOption "Enable OneAPI for Intel hardware";

  config = lib.mkIf config.oneapi.enable {
    environment.systemPackages = [
      config.nur.repos.gricad.intel-oneapi
    ];

  };
}
