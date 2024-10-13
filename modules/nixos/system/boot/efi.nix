{
  config,
  lib,
  ...
}: {
  options.efi.enable = lib.mkEnableOption "Use EFI for booting the system";

  config = lib.mkIf config.efi.enable {
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
