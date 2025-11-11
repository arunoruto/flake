{
  pkgs,
  lib,
  ...
}:
{
  # display-manager.enable = lib.mkForce false;
  # desktop-environment.enable = lib.mkForce false;
  display-manager.enable = false;
  desktop-environment.enable = false;
  services.media.enable = true;

  firefox.enable = false;
  chrome.enable = false;
  steam.enable = false;

  # Set hostname
  networking.hostName = lib.mkForce "narouter"; # Define your hostname.

  # boot = {
  #   kernelModules = ["amdgpu"];
  #   # kernelParams = [
  #   #   #"quiet"
  #   #   #"splash"
  #   #   "ahci.mobile_lpm_policy=3"
  #   #   # For Power consumption
  #   #   # https://kvark.github.io/linux/framework/2021/10/17/framework-nixos.html
  #   #   "mem_sleep_default=deep"
  #   # ];
  #   # initrd.kernelModules = ["i915"];
  # };

}
