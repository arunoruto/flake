{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.boot.loader.systemd-boot.enable {
    boot.loader = {
      systemd-boot = {
        memtest86.enable = (pkgs.system == "x86_64-linux");
      };
      efi.canTouchEfiVariables = lib.mkDefault true;
    };
  };
}
