# Facter-only host: no hardware-configuration.nix. Kernel modules, microcode,
# DHCP interfaces and the host platform all come from ./facter.json (loaded
# automatically by systems/default.nix); the filesystems come from ./disk.nix.
{ config, ... }:
{
  imports = [ ./disk.nix ];

  users.primaryUser = "mirza";

  system.tags = [ "server" ];

  colmena.deployment = {
    targetHost = config.networking.hostName;
  };
  hosts.intel.enable = true;

  # The Imaging Source DZK 33UX250 (USB3 Vision via Aravis): user access + a usbfs
  # buffer large enough for full 5 MP frames (default 16 MB gives size-mismatch errors).
  boot.kernelParams = [ "usbcore.usbfs_memory_mb=1000" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="199e", MODE="0660", GROUP="video", TAG+="uaccess"
  '';
}
