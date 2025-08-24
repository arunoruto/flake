{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ "${inputs.nixpkgs-unstable.outPath}/nixos/modules/hardware/fw-fanctrl.nix" ];
  colmena.deployment.allowLocalDeployment = lib.mkDefault true;

  system.tags = [ "laptop" ];
  hosts = {
    amd.enable = true;
  };
  tpm.enable = false;

  # services = {
  #   auto-cpufreq.enable = true;
  #   power-profiles-daemon.enable = false;
  #   tlp.enable = false;
  # };

  # Fix 6GHz problem
  # https://community.frame.work/t/responded-amd-rz616-wifi-card-doesnt-work-with-6ghz-on-kernel-6-7/43226
  boot = {
    extraModprobeConfig = ''
      options mt7921_common disable_clc=1
    '';
    blacklistedKernelModules = [ "hid_sensor_hub" ];
  };

  hardware = {
    fw-fanctrl = {
      enable = true;
      package = pkgs.unstable.fw-fanctrl;
    };
    # framework.enableKmod = false;
  };
}
