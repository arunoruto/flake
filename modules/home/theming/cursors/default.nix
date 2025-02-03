{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.theming.cursors.enable = lib.mkEnableOption "Setup cursors for system";

  config = lib.mkIf config.theming.cursors.enable {
    stylix.cursor = {
      # name = "catppuccin-macchiato-dark-cursors";
      # package = pkgs.catppuccin-cursors.macchiatoDark;
      name = "Banana";
      package = pkgs.banana-cursor;
      size = 24;
    };

    home.packages = with pkgs; [
      apple-cursor
      banana-cursor
      catppuccin-cursors
    ];
    # home.file = {
    #   ".local/share/icons/candy-icons" = {
    #     # recursive = true;
    #     source = "${candy-icons}";
    #   };
    # };
  };
}
