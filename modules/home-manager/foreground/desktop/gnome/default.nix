{
  lib,
  pkgs,
  config,
  osConfig ? null,
  ...
}:
let
  # GNOME's home config follows the GNOME session, the same way the
  # compositors follow theirs. Standalone home-manager has no system to ask
  # and keeps the old "any Linux desktop" default.
  hasGnome =
    if osConfig != null then
      osConfig.services.desktopManager.gnome.enable or false
    else
      config.desktop.enable;
in
{
  imports = [
    ./dconf.nix # gated on the same session test
  ];

  config = lib.mkIf hasGnome {
    gtk = {
      enable = true;
      gtk4.theme = lib.mkDefault null;
    };

    # Standalone only: under NixOS the system ships the portals and their
    # per-desktop config (modules/nixos/desktop/wayland.nix). A home-manager
    # copy repoints NIX_XDG_DESKTOP_PORTAL_DIR at just these two backends,
    # which hides the KDE portal from a Plasma session on the same host.
    xdg.portal = lib.mkIf (osConfig == null) {
      enable = lib.mkDefault true;
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
