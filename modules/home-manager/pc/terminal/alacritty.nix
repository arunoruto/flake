{
  config,
  ...
}:
{

  programs.alacritty = {
    settings = {
      terminal.shell = {
        program = config.shell.main;
      };
      window = {
        decorations = "full";
        dimensions = {
          columns = config.terminals.width;
          lines = config.terminals.height;
        };
        # opacity = 1;
        # blur = true;
      };
      # font = {
      #   size = 12;
      #   offset = {
      #     y = 0;
      #     x = 0;
      #   };
      #   glyph_offset = {
      #     y = 0;
      #     x = 0;
      #   };
      # };
    };
  };
}
