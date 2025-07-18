{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.boot.loader.grub.enable {
    boot.loader.grub = {
      # device = "/dev/sda";
      useOSProber = true;
      efiSupport = config.boot.loader.efi.canTouchEfiVariables;
    };
  };
}
