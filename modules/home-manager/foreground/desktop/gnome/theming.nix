{
  lib,
  config,
  ...
}:
{
  options.gnome.theming.enable = lib.mkEnableOption "Set GNOME theming through nix (only icons)";

  config = lib.mkIf config.gnome.theming.enable {
    gtk = {
      enable = true;
      gtk4.theme = lib.mkDefault null;
      # theme = {
      #   name = catppuccin_name;
      #   package = catppuccin_pkg;
      # };
      # cursorTheme = {
      #   name = "Catppuccin-Macchiato-Dark-Cursors";
      #   package = pkgs.catppuccin-cursors.macchiatoDark;
      # };
    };
  };
}
