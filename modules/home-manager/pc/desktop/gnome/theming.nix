{
  pkgs,
  lib,
  ...
}: let
  flavor = "Macchiato";
  accent = "Green";
  bright = "Dark";
  catppuccin_name = "Catppuccin-${flavor}-Standard-${accent}-${lib.strings.toLower bright}";
  catppuccin_path = "Catppuccin-${flavor}-Standard-${accent}-${bright}";
  #catppuccin_pkg = pkgs.catppuccin-gtk.override {
  #  accents = ["${lib.strings.toLower accent}"];
  #  size = "standard";
  #  tweaks = ["normal"];
  #  variant = lib.strings.toLower flavor;
  #};
  candy-icons = pkgs.fetchFromGitHub {
    owner = "EliverLara";
    repo = "candy-icons";
    rev = "5918a12632bf9c768cd1ad7a161076e3d72da60d";
    sha256 = "sha256-pmw3lflD1Kq/qO6iGDh3myWQF8mm1FABZPFB8/1Ql7Q=";
  };
in {
  # gtk settings
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

  #home.sessionVariables.GTK_THEME = catppuccin_name;
  home.file = {
    #   ".config/gtk-4.0/assets" = {
    #     recursive = true;
    #     source = "${catppuccin_pkg}/share/themes/${catppuccin_path}/gtk-4.0/assets";
    #   };
    #   ".config/gtk-4.0/gtk.css".source =      "${catppuccin_pkg}/share/themes/${catppuccin_path}/gtk-4.0/gtk.css";
    #   ".config/gtk-4.0/gtk-dark.css".source = "${catppuccin_pkg}/share/themes/${catppuccin_path}/gtk-4.0/gtk-dark.css";
    ".local/share/icons/candy-icons" = {
      # recursive = true;
      source = "${candy-icons}";
    };
  };
}
