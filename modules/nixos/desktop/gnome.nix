{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.gnome.enable = lib.mkEnableOption "Use the GNOME desktop environment";

  config = lib.mkIf config.gnome.enable {
    services = {
      xserver.desktopManager.gnome = {
        enable = true;
        extraGSettingsOverridePackages = with pkgs; [
          # gnome.mutter
        ];
      };
      gnome = {
        gnome-keyring.enable = true;
        gnome-remote-desktop.enable = config.hosts.workstation.enable;
        sushi.enable = true;
      };
      # For gestures
      libinput.enable = true;
      touchegg.enable = true;
    };

    programs.dconf.enable = lib.mkDefault true;

    environment = {
      systemPackages = with pkgs; [
        gnome-network-displays
        gthumb
        nautilus-open-any-terminal
        nautilus-python
        gnome-software
        gnome-pomodoro
        gnome-remote-desktop
        gnome-tweaks
        zenity
      ];
      # Excluding some GNOME applications from the default install
      gnome.excludePackages =
        (with pkgs; [
          gnome-photos
          gnome-tour
        ])
        ++ (with pkgs; [
          #cheese # webcam tool
          gnome-music
          gnome-terminal
          #gedit # text editor
          epiphany # web browser
          geary # email reader
          #evince # document viewer
          #gnome-characters
          totem # video player
          tali # poker game
          iagno # go game
          # hitori # sudoku game
          atomix # puzzle game
        ]);
    };

    networking.firewall = {
      allowedTCPPorts = [
        7236
        7250
      ] ++ lib.optionals config.services.gnome.gnome-remote-desktop.enable [ 3389 ];
      allowedUDPPorts = [
        7236
        5353
      ] ++ lib.optionals config.services.gnome.gnome-remote-desktop.enable [ 3389 ];
    };

    systemd.services.gnome-remote-desktop = {
      wantedBy = [ "graphical.target" ];
    };
  };
}
