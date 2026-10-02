{ mkTarget, ... }:
mkTarget {
  config =
    { colors }:
    {
      programs.atuin = {
        settings.theme.name = "stylix";
        themes.stylix = with colors.withHashtag; {
          theme.name = "stylix";
          colors = {
            # General UI elements
            Base = base03; # Darkest background
            Guidance = base05; # Main foreground text
            Title = base0D; # Primary accent color for titles/headings
            Annotation = base04; # Lighter gray for secondary text/annotations
            Important = base0E; # Highlighted or important elements

            # Alert messages
            AlertInfo = base0B;
            AlertWarn = base09;
            AlertError = base08;
          };
        };
      };
    };
}
