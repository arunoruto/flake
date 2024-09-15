{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    intel.enable = lib.mkEnableOption "Setup intel tools";
  };

  config = lib.mkIf config.intel.enable {
    environment.systemPackages = with pkgs; [
      intel-gpu-tools
    ];
  };
}
