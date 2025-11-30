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

    environment.systemPackages =
      (with pkgs; [
        usbutils # For lsusb
        virt-manager # For virt-install
        libvirt # libvirt client tools
        bridge-utils # Network bridge utilities
      ])
      ++ [ config.virtualisation.libvirtd.qemu.package ]; # QEMU with KVM support
  };
}
