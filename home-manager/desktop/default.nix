{pkgs, ...}: {
  imports = [
    #./programs/steam.nix

    ./bars
    ./gnome
    ./sway
    ./hyprland
    # ./kde.nix

    ../gui
  ];

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
    #via
    #vial
    #qbittorrent

    exercism

    gnomeExtensions.appindicator
    gnomeExtensions.emoji-copy
    # gnomeExtensions.focus
    #gnomeExtensions.spotify-controller
    gnomeExtensions.spotify-tray
    gnomeExtensions.tailscale-status
    gnomeExtensions.transparent-top-bar
  ];
}
