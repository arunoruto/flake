# Stylix targets that have no Darwin equivalent (Linux WMs, launchers,
# notification daemons, X11 tools, ...). Force them off so evaluating a Darwin
# home configuration doesn't try to theme software that isn't there.
{
  lib,
  pkgs,
  ...
}:
{
  config.stylix.targets = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    # Wayland/Linux window managers and compositors
    hyprland.enable = lib.mkForce false;
    hyprpaper.enable = lib.mkForce false;
    hyprlock.enable = lib.mkForce false;
    hyprpanel.enable = lib.mkForce false;
    sway.enable = lib.mkForce false;
    swaylock.enable = lib.mkForce false;
    swaync.enable = lib.mkForce false;
    waybar.enable = lib.mkForce false;
    wayfire.enable = lib.mkForce false;
    wayprompt.enable = lib.mkForce false;
    river.enable = lib.mkForce false;
    i3.enable = lib.mkForce false;
    i3bar-river.enable = lib.mkForce false;
    bspwm.enable = lib.mkForce false;

    # Linux-specific launchers and menus
    rofi.enable = lib.mkForce false;
    wofi.enable = lib.mkForce false;
    fuzzel.enable = lib.mkForce false;
    tofi.enable = lib.mkForce false;
    bemenu.enable = lib.mkForce false;

    # Linux-specific notification daemons
    dunst.enable = lib.mkForce false;
    mako.enable = lib.mkForce false;
    fnott.enable = lib.mkForce false;

    # Linux-specific system tools
    avizo.enable = lib.mkForce false;
    wob.enable = lib.mkForce false;

    # GNOME-specific
    gnome.enable = lib.mkForce false;
    gnome-text-editor.enable = lib.mkForce false;
    gedit.enable = lib.mkForce false;
    eog.enable = lib.mkForce false;

    # KDE/Qt (might work on macOS but typically Linux)
    kde.enable = lib.mkForce false;

    # XFCE
    xfce.enable = lib.mkForce false;

    # X11 specific
    xresources.enable = lib.mkForce false;
    sxiv.enable = lib.mkForce false;
    feh.enable = lib.mkForce false;

    # Wallpaper daemons (Linux-specific)
    wpaperd.enable = lib.mkForce false;

    # fcitx5 input method (primarily Linux)
    fcitx5.enable = lib.mkForce false;
  };
}
