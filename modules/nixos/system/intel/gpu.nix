{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.hosts.intel.gpu.enable = lib.mkEnableOption "Setup Intel GPU";

  config = lib.mkIf config.hosts.intel.gpu.enable {
    environment.systemPackages = with pkgs; [
      intel-gpu-tools
    ];

    hardware.graphics = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs; [
        vpl-gpu-rt
      ];
    };
  };
}
