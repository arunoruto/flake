{
  lib,
  pkgs,
  ...
}:
{
  users.primaryUser = "mirza";

  system.tags = [ "server" ];

  networking = {
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
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      # The GPU (V3D) and its display driver, instead of the firmware's
      # plain framebuffer; sets the device tree filter itself.
      fkms-3d.enable = true;
    };
    deviceTree.enable = true;
  };

  # Retro games on the attached screen: no Steam here (the Pi 4's CPU lacks
  # the LSE atomics Valve's ARM64 client needs), so it boots into RetroArch.
  # The unfree cores are the fast ones on ARM.
  steamix.emulation = {
    enable = true;
    kiosk.enable = true;
    retroarch.cores = with pkgs.libretro; [
      nestopia
      snes9x
      genesis-plus-gx
      mgba
      pcsx-rearmed
    ];
  };
  # console.enable = false;
  environment.systemPackages = with pkgs; [
    # helix
    # btop
    # git
    # tmux

    libraspberrypi
    raspberrypi-eeprom
  ];
  # system.stateVersion = "25.05";
}
