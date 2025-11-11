{
  lib,
  pkgs,
  ...
}:
{
  networking = {
    hostName = "pi";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

  services = {
    hardware.argonone.enable = true;
    tailscale.enable = true;
  };

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };
  # console.enable = false;
  environment.systemPackages = with pkgs; [
    helix
    btop
    git
    tmux

    libraspberrypi
    raspberrypi-eeprom
  ];
  # system.stateVersion = "25.05";
}
