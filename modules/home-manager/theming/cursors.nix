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

    # NOTE: Cursor configuration is handled by stylix at the system level
    # (nixosModules.stylix or darwinModules.stylix) which automatically
    # configures home.pointerCursor with name, package, and size.
    # We only provide additional cursor packages here.
  };
}
