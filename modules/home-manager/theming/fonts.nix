# https://danth.github.io/stylix/
{
  config,
  pkgs,
  lib,
  ...
}: {
  options.theming.fonts.enable = lib.mkEnableOption "Setup fonts on system";

  config = lib.mkIf config.theming.fonts.enable {
    stylix.fonts = rec {
      serif = {
        name = "Cantarell";
        package = pkgs.cantarell-fonts;
      };
      # serif = {
      #   name = "Roboto";
      #   package = pkgs.roboto;
      # };
      # sansSerif = config.stylix.fonts.serif;
      sansSerif = serif;
      # sansSerif = {
      #   name = "Roboto Serif";
      #   package = pkgs.roboto-serif;
      # };
      monospace = {
        name = "FiraCode Nerd Font";
        package = pkgs.fira-code-nerdfont;
      };
    };
  };
}
