{
  pkgs,
  lib,
  config,
  ...
}:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  config = lib.mkIf (config.desktop.enable && isLinux) {
    home.packages = with pkgs; [
      banana-cursor
      catppuccin-cursors
    ];

    # Force banana cursor to override Stylix's auto-configuration
    # Users can still override with mkForce in their personal config if needed
    stylix.cursor = {
      name = lib.mkForce "banana";
      package = lib.mkForce pkgs.banana-cursor;
      size = lib.mkDefault 24;
    };

    # Also set home.pointerCursor for applications that don't use stylix
    home.pointerCursor = {
      name = lib.mkForce "banana";
      package = lib.mkForce pkgs.banana-cursor;
      size = lib.mkDefault 24;
      gtk.enable = lib.mkDefault true;
      x11.enable = lib.mkDefault true;
    };
  };
}
