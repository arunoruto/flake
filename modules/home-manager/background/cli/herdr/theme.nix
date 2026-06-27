{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  colors = config.lib.stylix.colors.withHashtag;
in
{
  config = mkIf config.programs.herdr.enable {
    programs.herdr.settings.theme = {
      name = "terminal";
      custom = {
        accent = colors.base0D;
        panel_bg = colors.base01;
        surface0 = colors.base02;
        surface1 = colors.base03;
        surface_dim = colors.base00;
        overlay0 = colors.base03;
        overlay1 = colors.base04;
        text = colors.base06;
        subtext0 = colors.base05;
        mauve = colors.base0E;
        green = colors.base0B;
        yellow = colors.base0A;
        red = colors.base08;
        blue = colors.base0D;
        teal = colors.base0C;
        peach = colors.base09;
      };
    };
  };
}
