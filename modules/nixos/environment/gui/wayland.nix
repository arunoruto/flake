{
  pkgs,
  lib,
  config,
  ...
}: {
  options.wayland.enable = lib.mkEnableOption "Setup wayland";

  config = lib.mkIf config.wayland.enable {
    xdg = {
      portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [
          # xdg-desktop-portal-wlr
          # xdg-desktop-portal-gtk
        ];
        xdgOpenUsePortal = true;
      };
    };
  };
}
