{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    #./programs/steam.nix

    ./bars
    ./gnome
    ./sway
    ./hyprland
    # ./kde.nix
  ];

  options.desktop.enable = lib.mkEnableOption "Enable desktop config";

  config = lib.mkIf config.desktop.enable {
    gnome.enable = lib.mkDefault true;
    hyprland.enable = lib.mkDefault true;
    sway.enable = lib.mkDefault false;

    home.packages = with pkgs; [
      gimp
      inkscape
      #jabref
      obs-studio
      #obsidian
      #okular
      rnote
      spotify
      telegram-desktop
      #ultrastardx
      via
      vial
      #qbittorrent

      exercism
    ];
  };
}
