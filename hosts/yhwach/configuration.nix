{
  workstation.enable = true;
  yubikey.signing = "giyu";
  nvidia.enable = true;
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

  # cosmic.enable = true;

  # Eanble fingerprint for framework laptop
  # fingerprint.enable = true;
}
