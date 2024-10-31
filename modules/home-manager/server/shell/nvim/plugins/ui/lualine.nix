{
  programs.nixvim = {
    plugins = {
      lualine = {
        enable = true;
        componentSeparators = {
          left = "";
          right = "";
        };
        sectionSeparators = {
          left = "";
          right = "";
        };
        sections = {
          lualine_a = [
            {
              name = "mode";
              separator.left = "";
              padding = {
                left = 0;
                right = 2;
              };
            }
          ];
          #lualine_b = [
          #  "filename"
          #  "branch"
          #];
          lualine_c = [
            #  #"%="
          ];
          lualine_x = [ ];
          #lualine_y = [
          #  "filetype"
          #  "progress"
          #];
          lualine_z = [
            {
              name = "location";
              separator.right = "";
              padding = {
                left = 2;
                right = 0;
              };
            }
          ];
        };
        inactiveSections = {
          lualine_a = [ "filename" ];
          lualine_b = [ ];
          lualine_c = [ ];
          lualine_x = [ ];
          lualine_y = [ ];
          lualine_z = [ "location" ];
        };
        tabline = {
          lualine_a = [ ];
          lualine_b = [ ];
          lualine_c = [ ];
          lualine_x = [ ];
          lualine_y = [ ];
          lualine_z = [ ];
        };
        extensions = [ ];
      };
    };
  };
}
