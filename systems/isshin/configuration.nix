{ lib, config, ... }:
{
  colmena.deployment.allowLocalDeployment = lib.mkDefault true;

  services = lib.mkIf (config.services ? ucodenix) {
    ucodenix.enable = true;
    # ucodenix.cpuModelId = "00A70F41";
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

  # hardware.framework.enableKmod = false;


}
