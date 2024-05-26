{
  programs.alacritty = {
    enable = true;
    settings = {
      shell = {
        program = "zsh";
      };
      window = {
        decorations = "full";
        dimensions = {
          columns = 108;
          lines = 36;
        };
        # opacity = 1;
        blur = true;
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
      #   bold = {
      #     style = "Bold";
      #     family = "FiraCode Nerd Font";
      #   };
      #   normal = {
      #     style = "Regular";
      #     family = "FiraCode Nerd Font";
      #   };
      # };
    };
  };
}
