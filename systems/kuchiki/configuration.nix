{
  config,
  pkgs,
  lib,
  ...
}:
{
  hosts.amd.enable = true;
  # display-manager.enable = lib.mkForce false;
  # desktop-environment.enable = lib.mkForce false;
  display-manager.enable = false;
  desktop-environment.enable = false;
  media.enable = true;

  # firefox.enable = false;
  # chrome.enable = false;
  # steam.enable = false;
  # home.pc.enable = false;
  programs.enable = false;

  boot = {
    kernelModules = [ "amdgpu" ];
  };

  services = {
    # hddfancontrol = {
    #   enable = false;
    #   disks = [
    #     "/dev/sda"
    #     "/dev/sdb"
    #   ];
    #   pwmPaths = [
    #     "/sys/class/hwmon/hwmon2/pwm1"
    #   ];
    # };
    beszel.agent = {
      enable = true;
      package = pkgs.unstable.beszel;
      environment = {
        LOG_LEVEL = "info";
        GPU = "true";
        KEY_FILE = config.sops.secrets."tokens/beszel-marvin".path;
        EXTRA_FILESYSTEMS = lib.strings.concatStringsSep "," [
          "nvme0n1p1"
        ];
      };
      openFirewall = true;
    };
  };

  sops.secrets."tokens/beszel-marvin".mode = "0444";
}
