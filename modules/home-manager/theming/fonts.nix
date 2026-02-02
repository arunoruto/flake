{
  config,
  pkgs,
  lib,
  ...
}:
let
  # roboto = {
  #   name = "Roboto";
  #   package = pkgs.roboto;
  # };
  cantarell = {
    name = "Cantarell";
    package = pkgs.cantarell-fonts;
  };
in
{
  options.theming.fonts.enable = lib.mkEnableOption "Setup fonts on system";

  config = lib.mkIf config.theming.fonts.enable {
    # NOTE: stylix.fonts is configured at system level (nixosModules.stylix or darwinModules.stylix)
    # which auto-configures home-manager font settings
    home.packages = [
      cantarell.package
      pkgs.nerd-fonts.fira-code
    ];
  };
}
