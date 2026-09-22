{
  pkgs,
  # lib,
  ...
}:
let
  # monitorsXmlContent = builtins.readFile /home/mar/.config/monitors.xml;
  # monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
  # monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile /home/${username}/.config/monitors.xml);
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile ./monitors.xml);
in
{
  users.primaryUser = "mar";

  # hardware-configuration.nix pulls in `broadcom_sta` for this machine's wifi.
  # The driver is unmaintained and carries known vulnerabilities; it is allowed
  # through ./nixpkgs.nix — by pname, so it survives nixpkgs and kernel bumps.
  # Nothing forces a re-look any more, so surface it on every rebuild instead.
  warnings = [
    ''
      kyuubi: the broadcom_sta wifi driver is flagged insecure upstream and is
      permitted unconditionally in systems/x86_64-linux/kyuubi/nixpkgs.nix.
      Drop both once the adapter is replaced or the driver is fixed.
    ''
  ];

  gui.enable = true; # Enable GUI programs (browsers, etc.)
  system.tags = [ "workstation" ];

  # Define your hostname.
  # networking.hostName = lib.mkForce "kyuubi";

  # Disable Autosuspend for USB Bluetooth dongles
  boot = {
    kernelModules = [ "snd-hda-intel " ];
    extraModprobeConfig = ''
      options btusb enable_autosuspend=n
    '';
  };

  services = {
    printing.enable = true;
    ipp-usb.enable = true; # driverless scanning; turns on SANE too
    nfs.server.enable = true;

    # Enable SSH Daemon
    # openssh = {
    #   enable = true;
    #   # require public key authentication for better security
    #   #settings.PasswordAuthentication = false;
    #   #settings.KbdInteractiveAuthentication = false;
    #   #settings.PermitRootLogin = "yes";
    # };
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
    bluetooth = {
      enable = true;
      settings = {
        General = {
          FastConnect = true;
          Experimental = true;
        };
        Policy = {
          ReconnectAttempts = 7;
          ReconnectIntervals = "1, 2, 3";
        };
      };
    };

    # OpenGL
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
    };
  };

  systemd = {
    tmpfiles.rules = [
      "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
    ];

    services.NetworkManager-wait-online = {
      serviceConfig = {
        ExecStart = [
          ""
          "${pkgs.networkmanager}/bin/nm-online -q"
        ];
      };
    };
  };
}
