{pkgs, ...}: {
  imports = [
    #./programs/steam.nix

    ./gnome
    ./sway
    ./hyprland
  ];

  home.packages = with pkgs; [
    gimp
    inkscape
    #jabref
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
    gnomeExtensions.emoji-selector
    gnomeExtensions.focus
    #gnomeExtensions.spotify-controller
    gnomeExtensions.spotify-tray
    gnomeExtensions.tailscale-status
    gnomeExtensions.transparent-top-bar
  ];
}
