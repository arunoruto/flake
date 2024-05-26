{
  config,
  lib,
  ...
}: {
  options = {
    drive-optimizations = lib.mkEnableOption "Enable drive optimizations";
  };

  config = lib.mkIf config.drive-optimizations.enable {
    # Periodic SSD TRIM of mounted partitions in background
    services.fstrim.enable = lib.mkDefault true;
  };
}
