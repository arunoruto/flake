{
  config,
  lib,
  ...
}:
{
  options.systemd-boot.enable = lib.mkEnableOption "Use systemd-boot as a boot manager";

  config = lib.mkIf config.systemd-boot.enable {
    boot.loader = {
      systemd-boot = {
        enable = lib.mkDefault true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = config.efi.enable;
    };
  };
}
