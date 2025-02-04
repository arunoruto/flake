{
  hosts = {
    workstation.enable = true;
    nvidia.enable = true;
  };
  yubikey.signing = "giyu";
  # netbird.enable = true;
  # fingerprint.enable = true;

  # Enable lanzaboote for secure-boot
  secureboot.enable = true;

  # Enable systemd-boot selection
  boot = {
    loader.timeout = 10;
    kernelParams = [ "nvidia.NVreg_EnableGpuFirmware=0" ];
  };

  # Set system time
  time.hardwareClockInLocalTime = true;
}
