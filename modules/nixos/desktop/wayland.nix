{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.wayland.enable = lib.mkEnableOption "Setup wayland";

  config = lib.mkIf config.wayland.enable {
    xdg = {
      portal = {
        enable = true;
        # The wlroots portal is for sway. GNOME and niri use the gnome portal
        # and Hyprland ships its own (xdph) that would fight it over
        # screencasting, so it follows sway instead of defaulting on.
        wlr.enable = lib.mkDefault config.programs.sway.enable;
        # `xdg.portal.wlr.enable` adds xdg-desktop-portal-wlr by itself.
        extraPortals =
          with pkgs;
          [
            xdg-desktop-portal
            xdg-desktop-portal-gtk
          ]
          ++ lib.optionals config.services.desktopManager.gnome.enable [
            pkgs.xdg-desktop-portal-gnome
          ];
        xdgOpenUsePortal = true;
      };
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];
  };
}
