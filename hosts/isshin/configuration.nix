{ lib, config, ... }:
{
  services = lib.mkIf (config.services ? ucodenix) {
    ucodenix.enable = true;
    ucodenix.cpuModelId = "00A70F41";
  };

  hosts = {
    laptop.enable = true;
    amd.enable = true;
  };
  tpm.enable = false;

  # Fix 6GHz problem
  # https://community.frame.work/t/responded-amd-rz616-wifi-card-doesnt-work-with-6ghz-on-kernel-6-7/43226
  boot.extraModprobeConfig = ''
    options mt7921_common disable_clc=1
  '';

  # Framework specific kernel Params
  # boot = {
  #   kernelParams = [
  #     #"quiet"
  #     #"splash"
  #     # "ahci.mobile_lpm_policy=3"
  #     # For Power consumption
  #     # https://kvark.github.io/linux/framework/2021/10/17/framework-nixos.html
  #     # "mem_sleep_default=deep"
  #   ];
  #   # initrd.kernelModules = ["i915"];
  # };
}
