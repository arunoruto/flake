{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    drives.enable = lib.mkEnableOption "Utilities for managing drives";
  };

  config = lib.mkIf config.drives.enable {
    environment.systemPackages = with pkgs; [
      smartmontools
    ];
  };
}
