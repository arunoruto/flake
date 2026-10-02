{ mkTarget, ... }:
mkTarget {
  config =
    { colors }:
    {
      programs.herdr.settings.theme = with colors.withHashtag; {
        name = "terminal";
        custom = {
          accent = base0D;
          panel_bg = base01;
          surface0 = base02;
          surface1 = base03;
          surface_dim = base00;
          overlay0 = base03;
          overlay1 = base04;
          text = base06;
          subtext0 = base05;
          mauve = base0E;
          green = base0B;
          yellow = base0A;
          red = base08;
          blue = base0D;
          teal = base0C;
          peach = base09;
        };
      };
    };
}
