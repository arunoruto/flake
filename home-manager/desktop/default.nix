{pkgs, ...}: {
  imports = [
    #./programs/steam.nix

    ./gnome
    ./sway
    ./hyprland
    # ./kde.nix
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
