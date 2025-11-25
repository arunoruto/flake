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
        wlr.enable = true;
        extraPortals =
          with pkgs;
          [
            xdg-desktop-portal
            xdg-desktop-portal-wlr
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
