{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    gnome.enable = lib.mkEnableOption "Use the GNOME desktop environment";
  };

  config = lib.mkIf config.gnome.enable {
    services = {
      xserver.desktopManager.gnome.enable = true;
      gnome.gnome-keyring.enable = true;
    };

    environment = {
      systemPackages = with pkgs; [
        gnome-network-displays
        nautilus-open-any-terminal
        gnome.nautilus-python
        gnome.gnome-software
        gnome.pomodoro
        gnome.gnome-remote-desktop
        gnome3.gnome-tweaks
      ];
      # Excluding some GNOME applications from the default install
      gnome.excludePackages =
        (with pkgs; [
          gnome-photos
          gnome-tour
        ])
        ++ (with pkgs.gnome; [
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
          hitori # sudoku game
          atomix # puzzle game
        ]);
    };

    networking.firewall = {
      allowedTCPPorts = [7236 7250];
      allowedUDPPorts = [7236 5353];
    };
  };
}
