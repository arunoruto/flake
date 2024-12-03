{
  pkgs,
  lib,
  ...
}:
{
  hosts.tinypc.enable = true;
  tpm.enable = true;

  #efi.enable = false;
  #grub.enable = true;
  #systemd-boot.enable = false;
  #boot.loader.grub.device = "/dev/sda";
  # boot.loader.efi.canTouchEfiVariables = false;
  # boot.loader = {
  #   systemd-boot.enable = false;
  #   grub = {
  #     enable = true;
  #     device = "/dev/sda";
  #     #useOSProber = true;
  #     efiSupport = false;
  #   };
  # };

  # Set hostname
  #networking.hostName = lib.mkForce "yoruichi"; # Define your hostname.

}
