{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.theming.cursors.enable = lib.mkEnableOption "Setup cursors for system";

  config = lib.mkIf config.theming.cursors.enable {
    home.packages = with pkgs; [
      apple-cursor
      banana-cursor
      catppuccin-cursors
    ];
    home.pointerCursor = {
      enable = true;
    };

    # NOTE: stylix.cursor is configured at system level (nixosModules.stylix)
    # which auto-configures home-manager cursor settings
  };
}
