{ ... }:
{
  system.tags = [
    "tinypc"
    "headless"
  ];
  colmena.deployment.buildOnTarget = false;

  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub.enable = true;
    systemd-boot.enable = false;

    grub.device = "/dev/sda";
  };
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
}
