{
  pkgs,
  lib,
  ...
}:
{
  hosts.tinypc.enable = true;
  hosts.intel.enable = true;
  kodi.enable = true;
  # tpm.enable = true;

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

  boot = {
    # kernelModules = ["amdgpu"];
    # kernelParams = [
    #   #"quiet"
    #   #"splash"
    #   "ahci.mobile_lpm_policy=3"
    #   # For Power consumption
    #   # https://kvark.github.io/linux/framework/2021/10/17/framework-nixos.html
    #   "mem_sleep_default=deep"
    # ];
    # initrd.kernelModules = ["i915"];
  };
}
