{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.hardware.custom.keyboard.enable = lib.mkEnableOption "Enable mouse config";

  config = lib.mkIf config.hardware.custom.keyboard.enable {
    hardware.keyboard.qmk.enable = true;
    environment.systemPackages = with pkgs; [
      via
      vial
    ];
    services.udev = {
      packages = with pkgs; [ via ];
      extraRules = ''
        ## Vial support
        ## https://get.vial.today/manual/linux-udev.html
        # Universal
        # KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
        # General
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
        # Piantor
        # KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="beeb", ATTRS{idProduct}=="0001", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl" 
      '';
    };
  };
}
