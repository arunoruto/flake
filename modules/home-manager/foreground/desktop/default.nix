{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [

    ./bars
    ./gnome
    ./sway
    ./hyprland
    ./niri

    ./notifications
  ];

  options.desktop.enable = lib.mkEnableOption "Enable desktop config";

  config = lib.mkIf config.desktop.enable {
    # GNOME, Hyprland, sway and niri each follow their NixOS session toggle
    # from inside their own directory -- a host without the session has no
    # reason to carry its config, services and packages.

    home.packages =
      (with pkgs; [
        # gimp
        # inkscape
        # obs-studio
        #okular
        # rnote
        # via
        # vial
        #qbittorrent

        # exercism
      ])
      ++ (with pkgs.unstable; [
        gimp3
        telegram-desktop
      ]);
  };
}
