{
  pkgs,
  lib,
  config,
  ...
}: let
  candy-icons = pkgs.fetchFromGitHub {
    owner = "EliverLara";
    repo = "candy-icons";
    rev = "b92b133d0ad7ed5b5e376bd00216a05652277209";
    sha256 = "sha256-0wsSjK8WrwM/yh40a76cYblbv52tdJGTKAdxNU43frc=";
  };
in {
  options.gnome.theming.enable = lib.mkEnableOption "Set GNOME theming through nix (only icons)";

  config = lib.mkIf config.gnome.theming.enable {
    gtk = {
      enable = true;
      # theme = {
      #   name = catppuccin_name;
      #   package = catppuccin_pkg;
      # };
      # cursorTheme = {
      #   name = "Catppuccin-Macchiato-Dark-Cursors";
      #   package = pkgs.catppuccin-cursors.macchiatoDark;
      # };
    };

    home.file.".local/share/icons/candy-icons" = {
      # recursive = true;
      source = "${candy-icons}";
    };
  };
}
