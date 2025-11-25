{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    #./programs/steam.nix

    ./bars
    ./gnome
    ./sway
    ./hyprland
    ./niri
    # ./kde.nix

    ./notifications
  ];

  options.desktop.enable = lib.mkEnableOption "Enable desktop config";

  config = lib.mkIf config.desktop.enable {
    gnome.enable = lib.mkDefault true;
    wayland.windowManager = {
      hyprland.enable = lib.mkDefault true;
      sway.enable = lib.mkDefault false;
    };
    xdg.portal.enable = lib.mkDefault true;

    home.packages =
      (with pkgs; [
        # gimp
        inkscape
        # jabref
        # obs-studio
        #okular
        rnote
        telegram-desktop
        # via
        # vial
        #qbittorrent

        exercism
      ])
      ++ (with pkgs.unstable; [ gimp3 ]);
  };
}
