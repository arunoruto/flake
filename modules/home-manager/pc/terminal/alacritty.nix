{
  lib,
  config,
  ...
}:
{
  options.terminals.alacritty.enable = lib.mkEnableOption "Enable alacritty config";

  config = lib.mkIf config.terminals.alacritty.enable {
    programs.alacritty = {
      enable = true;
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
  };
}
