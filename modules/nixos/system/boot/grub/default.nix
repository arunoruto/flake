{
  config,
  lib,
  ...
}:
{
  options.grub.enable = lib.mkEnableOption "Use grub as a boot manager";

  config = lib.mkIf config.grub.enable {
    boot.loader.grub = {
      enable = true;
      # device = "/dev/sda";
      useOSProber = true;
      efiSupport = config.efi.enable;
    };
  };
}
