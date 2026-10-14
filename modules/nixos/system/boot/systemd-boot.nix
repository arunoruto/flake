{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.boot.loader.systemd-boot.enable {
    boot.loader = {
      systemd-boot.memtest86.enable = true;
      systemd-boot.configurationLimit = lib.mkDefault 10;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };
  };
}
