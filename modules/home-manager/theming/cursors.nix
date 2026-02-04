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
      apple-cursor
      banana-cursor
      catppuccin-cursors
    ];

    # User-level cursor: banana
    # This sets the cursor for the user's session via Stylix
    stylix.cursor = {
      name = lib.mkDefault "Banana";
      package = lib.mkDefault pkgs.banana-cursor;
      size = lib.mkDefault 24;
    };
  };
}
