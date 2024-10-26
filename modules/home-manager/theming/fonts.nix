{
  config,
  pkgs,
  lib,
  ...
}: let
  cantarell = {
    name = "Cantarell";
    package = pkgs.cantarell-fonts;
  };
  # roboto = {
  #   name = "Roboto";
  #   package = pkgs.roboto;
  # };
in {
  options.theming.fonts.enable = lib.mkEnableOption "Setup fonts on system";

  config = lib.mkIf config.theming.fonts.enable {
    stylix.fonts = {
      serif = cantarell;
      sansSerif = cantarell;
      monospace = {
        name = "FiraCode Nerd Font";
        package = pkgs.fira-code-nerdfont;
      };
    };
  };
}
