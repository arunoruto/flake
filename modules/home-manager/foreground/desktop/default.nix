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
    gnome.enable = lib.mkDefault true;
    # hyprland follows the NixOS toggle (see hyprland/default.nix), the same
    # way niri does -- a host that has no Hyprland session has no reason to
    # carry its config, services and packages.
    wayland.windowManager.sway.enable = lib.mkDefault false;
    xdg.portal.enable = lib.mkDefault true;

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
