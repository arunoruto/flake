{
  pkgs,
  config,
  lib,
  ...
}:
{
  # imports = [
  #   ./oneapi.nix
  # ];

  options.hosts.intel.enable = lib.mkEnableOption "Setup intel tools";

  config = lib.mkIf config.hosts.intel.enable {
    hosts.intel.oneapi.enable = lib.mkDefault false;

    environment.systemPackages = with pkgs; [
      intel-gpu-tools
    ];
  };
}
