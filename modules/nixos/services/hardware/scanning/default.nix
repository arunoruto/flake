{
  config,
  lib,
  ...
}:
{
  options = {
    scanning.enable = lib.mkEnableOption "Enable scanning support";
  };

  config = lib.mkIf config.scanning.enable {
    # Enable scanning for USB devices
    services.ipp-usb.enable = true;

    # Enable scanning
    hardware.sane = {
      enable = true;
    };
  };
}
