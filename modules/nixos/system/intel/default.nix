{
  config,
  lib,
  ...
}:
{
  imports = [
    ./gpu.nix
    ./oneapi.nix
  ];

  options.hosts.intel.enable = lib.mkEnableOption "Setup intel tools";

  config = lib.mkIf config.hosts.intel.enable {
    # hosts.intel.oneapi.enable = lib.mkDefault false;
  };
}
