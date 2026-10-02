{ mkTarget, ... }:
mkTarget {
  config =
    { colors }:
    {
      programs.tuios = {
        settings.appearance.theme = "stylix";
        themes.stylix = with colors.withHashtag; {
          display_name = "Stylix";

          fg = base05;
          bg = base00;
          cursor = base05;

          black = base00;
          red = base08;
          green = base0B;
          yellow = base0A;
          blue = base0D;
          purple = base0E;
          cyan = base0C;
          white = base05;

          bright_black = base03;
          bright_red = base08;
          bright_green = base0B;
          bright_yellow = base0A;
          bright_blue = base0D;
          bright_purple = base0E;
          bright_cyan = base0C;
          bright_white = base07;
        };
      };
    };
}
