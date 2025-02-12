{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.hosts.intel.oneapi.enable = lib.mkEnableOption "Enable OneAPI for Intel hardware";

  config = lib.mkIf config.hosts.intel.oneapi.enable {
    environment.systemPackages = [
      config.nur.repos.gricad.intel-oneapi
    ];

  };
}
