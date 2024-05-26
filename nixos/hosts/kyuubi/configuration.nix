{
  config,
  pkgs,
  lib,
  ...
}: let
  monitorsXmlContent = builtins.readFile /home/mar/.config/monitors.xml;
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in {
  # Disable Autosuspend for USB Bluetooth dongles
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=n
  '';

  # Define your hostname.
  networking.hostName = lib.mkForce "kyuubi";

  users.users.mar = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Mirza";
    extraGroups = ["dialout" "networkmanager" "wheel" "scanner" "lp" "video"];
    packages = with pkgs; [
      #  firefox
      #  thunderbird
    ];
  };

  # Enable SSH Daemon
  services = {
    openssh = {
      enable = true;
      # require public key authentication for better security
      #settings.PasswordAuthentication = false;
      #settings.KbdInteractiveAuthentication = false;
      #settings.PermitRootLogin = "yes";
    };
    # xrdp = {
    #   enable = true;
    #   defaultWindowManager = "gnome-remote-desktop";
    #   openFirewall = true;
    # };
    gnome.gnome-remote-desktop.enable = true;
  };

  # Make logitech devices work easier
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # Tweaks for keychron
  hardware.bluetooth.settings = {
    General = {
      FastConnect = true;
    };
    Policy = {
      ReconnectAttempts = 7;
      ReconnectIntervals = "1, 2, 3";
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  ];

  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
    };
  };
}
