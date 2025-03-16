{ ... }:
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

  services.hddfancontrol = {
    enable = false;
    disks = [
      "/dev/sda"
      "/dev/sdb"
    ];
    pwmPaths = [
      "/sys/class/hwmon/hwmon2/pwm1"
    ];
  };
}
