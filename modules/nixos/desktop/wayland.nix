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
        # Hyprland ships its own portal (xdph, pulled in by the NixOS module)
        # and the two fight over the screencast interface, so the wlroots
        # portal is only for the other wlr compositors (sway).
        wlr.enable = lib.mkDefault (!config.programs.hyprland.enable);
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
