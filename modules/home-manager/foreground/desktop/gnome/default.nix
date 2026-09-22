{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./dconf.nix
    ./theming.nix
  ];

  options.gnome.enable = lib.mkEnableOption "Enable custom GNOME config";

  config = lib.mkIf config.gnome.enable {
    gnome = {
      dconf.enable = lib.mkDefault true;
      theming.enable = lib.mkDefault true;
    };

    dconf.enable = lib.mkForce config.gnome.dconf.enable;

    xdg.portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      # Which backend serves which interface under GNOME
      # (gnome-portals.conf: gnome, then gtk) -- the same package the NixOS
      # gnome module uses. Without it home-manager warns that portal loading is
      # unconfigured; the hyprland module used to mask that by always shipping
      # its own hyprland-portals.conf, which never applied to a GNOME session.
      configPackages = lib.mkDefault [ pkgs.gnome-session ];
    };

    home.packages =
      with pkgs.gnomeExtensions;
      [
        appindicator
        auto-move-windows
        blur-my-shell
        emoji-copy
        framework-fan-control
        # focus
        forge
        pip-on-top
        smart-auto-move
        tactile
        tiling-shell
        toggler
        tophat
        # transparent-top-bar
        transparent-top-bar-adjustable-transparency
      ]
      ++ (with pkgs.unstable.gnomeExtensions; [
        # pip-on-top
        tailscale-status
        tailscale-qs
        # tiling-shell
      ]);
  };
}
