{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./oneapi.nix
  ];

  options = {
    intel.enable = lib.mkEnableOption "Setup intel tools";
  };

  config = lib.mkIf config.intel.enable {
    oneapi.enable = lib.mkDefault false;

    environment.systemPackages = with pkgs; [
      intel-gpu-tools
    ];
  };
}
