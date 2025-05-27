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
    stylix.fonts = {
      serif = cantarell;
      sansSerif = cantarell;
      # monospace = {
      #   name = "CaskaydiaCove Nerd Font Mono";
      #   package = pkgs.nerd-fonts.caskaydia-cove;
      # };
      # monospace = {
      #   name = "JetBrains Mono";
      #   package = pkgs.nerd-fonts.jetbrains-mono;
      # };
      monospace = {
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerd-fonts.fira-code;
      };
    };
  };
}
