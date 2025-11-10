{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.virtualisation.libvirtd.enable {
    virtualisation = {
      libvirtd = {
        qemu = {
          package = pkgs.qemu_kvm;
          ovmf = {
            enable = true;
            packages = [ pkgs.OVMF ];
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      virt-manager # For virt-install
      usbutils # For lsusb
    ];
  };
}
