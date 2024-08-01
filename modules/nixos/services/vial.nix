{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    vial.enable = lib.mkEnableOption "Support vial for custom keyboards";
  };

  config = lib.mkIf config.vial.enable {
    # Packages with udev rules
    services.udev = {
      packages = with pkgs; [
        vial
      ];
      extraRules = ''
        # Vial support
        # https://get.vial.today/manual/linux-udev.html
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
        # Fix headphone noise when on powersave
        # https://community.frame.work/t/headphone-jack-intermittent-noise/5246/55
        SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0xa0e0", ATTR{power/control}="on"
        # Ethernet expansion card support
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", ATTR{power/autosuspend}="20"
      '';
    };
  };
}
