{
  config,
  pkgs,
  lib,
  username,
  ...
}: let
  # monitorsXmlContent = builtins.readFile /home/mar/.config/monitors.xml;
  # monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
  # monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile /home/${username}/.config/monitors.xml);
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile ./monitors.xml);
in {
  imports = [
    ./hardware-configuration.nix
    ../..
  ];

  printing.enable = true;
  scanning.enable = true;

  # Define your hostname.
  networking.hostName = lib.mkForce "kyuubi";

  environment.sessionVariables.FLAKE = "/home/${username}/Development/nix";

  # Disable Autosuspend for USB Bluetooth dongles
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=n
  '';

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

  hardware = {
    # Make logitech devices work easier
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    # Tweaks for keychron
    bluetooth.settings = {
      General = {
        FastConnect = true;
      };
      Policy = {
        ReconnectAttempts = 7;
        ReconnectIntervals = "1, 2, 3";
      };
    };
  };

  systemd = {
    tmpfiles.rules = [
      "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
    ];

    services.NetworkManager-wait-online = {
      serviceConfig = {
        ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
      };
    };
  };
}
