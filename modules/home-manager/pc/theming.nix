# https://danth.github.io/stylix/
{
  config,
  pkgs,
  lib,
  ...
}: {
  # If desktop is enabled, also enable theming using stylix
  config = lib.mkIf config.desktop.enable {
    stylix = {
      cursor = {
        name = "catppuccin-macchiato-dark-cursors";
        package = pkgs.catppuccin-cursors.macchiatoDark;
        size = 24;
      };
      fonts = {
        serif = {
          name = "Cantarell";
          package = pkgs.cantarell-fonts;
        };
        # serif = {
        #   name = "Roboto";
        #   package = pkgs.roboto;
        # };
        sansSerif = config.stylix.fonts.serif;
        # sansSerif = {
        #   name = "Roboto Serif";
        #   package = pkgs.roboto-serif;
        # };
        monospace = {
          name = "FiraCode Nerd Font";
          package = pkgs.fira-code-nerdfont;
        };
      };
      opacity = {
        terminal = 0.95;
      };
      targets = {
        firefox = {
          enable = false;
          # profileNames = ["mirza"];
        };
        # hyprland.enable = true;
        # hyprpaper.enable = true;
        # helix.enable = false;
        # kde.enable = false;
        # mako.enable = false;
        # nixvim.enable = false;
      };
    };
  };
}
