{
  config,
  pkgs,
  lib,
  ...
}:
let
  cantarell = {
    name = "Cantarell";
    package = pkgs.cantarell-fonts;
  };
in
# roboto = {
#   name = "Roboto";
#   package = pkgs.roboto;
# };
{
  options.theming.fonts.enable = lib.mkEnableOption "Setup fonts on system";

  config = lib.mkIf config.theming.fonts.enable {
    stylix.fonts = {
      serif = cantarell;
      sansSerif = cantarell;
      monospace = {
        name = "FiraCode Nerd Font";
        package = pkgs.fira-code;
        # package = pkgs.fira-code-nerdfont;
      };
    };
  };
}
