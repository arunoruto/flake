{
  programs.nixvim = {
    plugins = {
      alpha = {
        enable = true;
        iconsEnabled = true;

        layout = [
          {
            type = "padding";
            val = 2;
          }
          {
            opts = {
              hl = "Type";
              position = "center";
            };
            type = "text";
            val = [
              "⠀⠀⠀⠀⠀⠀⠀⢀⠀⠔⡀⠀⢀⠞⢰⠂⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⢸⠘⢰⡃⠔⠩⠤⠦⠤⢀⡀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⢀⠄⢒⠒⠺⠆⠈⠀⠀⢐⣂⠤⠄⡀⠯⠕⣒⣒⡀⠀"
              "⠀⠀⢐⡡⠔⠁⠆⠀⠀⠀⠀⠀⢀⠠⠙⢆⠀⠈⢁⠋⠥⣀⣀"
              "⠈⠉⠀⣰⠀⠀⠀⠀⡀⠀⢰⣆⢠⠠⢡⡀⢂⣗⣖⢝⡎⠉⠀"
              "⢠⡴⠛⡇⠀⠐⠀⡄⣡⢇⠸⢸⢸⡇⠂⡝⠌⢷⢫⢮⡜⡀⠀"
              "⠀⠀⢰⣜⠘⡀⢡⠰⠳⣎⢂⣟⡎⠘⣬⡕⣈⣼⠢⠹⡟⠇⠀"
              "⠀⠠⢋⢿⢳⢼⣄⣆⣦⣱⣿⣿⣿⣷⠬⣿⣿⣿⣿⠑⠵⠀⠀"
              "⠀⠀⠀⡜⢩⣯⢝⡀⠁⠀⠙⠛⠛⠃⠀⠈⠛⠛⡿⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⣿⠢⡁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀"
              "⠀⠀⠀⠀⢀⣀⡇⠀⠑⠀⠀⠀⠀⠐⢄⠄⢀⡼⠃⠀⠀⠀⠀"
              "⠀⠀⠀⠀⢸⣿⣷⣤⣀⠈⠲⡤⣀⣀⠀⡰⠋⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣶⣤⣙⣷⣅⡀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⢀⣾⣿⣿⣿⣿⣻⢿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀"
              "⠀⡠⠟⠁⠙⠟⠛⠛⢿⣿⣾⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀"
            ];
          }
          {
            type = "padding";
            val = 2;
          }
          {
            type = "group";
            val = [
              {
                val = "   New File";
                # on_press = "<cmd>ene <cr>";
                on_press.__raw = "function() vim.cmd[[ene]] end";
                type = "button";
                opts = {
                  shortcut = "e";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                };
              }
              {
                val = "   Toggle file explorer";
                # on_press = "<cmd>NvimTreeToggle<CR>";
                on_press.__raw = "function() vim.cmd[[NvimTreeToggle]] end";
                type = "button";
                opts = {
                  shortcut = "SPC ee";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                };
              }
              {
                val = "󰱼   Find File";
                # on_press = "<cmd>Telescope find_files<CR>";
                on_press.__raw = "function() vim.cmd[[Telescope find_files]] end";
                type = "button";
                opts = {
                  shortcut = "SPC ff";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                };
              }
              {
                val = "   Find Word";
                # on_press = "<cmd>Telescope live_grep<CR>";
                on_press.__raw = "function() vim.cmd[[Telescope live_grep]] end";
                type = "button";
                opts = {
                  shortcut = "SPC fs";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                };
              }
              {
                val = "󰁯   Restore Session For Current Directory";
                # on_press = "<cmd>SessionRestore<CR>";
                on_press.__raw = "function() vim.cmd[[SessionRestore]] end";
                type = "button";
                opts = {
                  shortcut = "SPC wr";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                };
              }
              {
                val = "   Quit NVIM";
                # on_press = "<cmd>qa<CR>";
                on_press.__raw = "function() vim.cmd[[qa]] end";
                type = "button";

                opts = {
                  shortcut = "SPC  q";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                };
              }
            ];
          }
          {
            type = "padding";
            val = 2;
          }
          {
            opts = {
              hl = "Keyword";
              position = "center";
            };
            type = "text";
            val = "Infinity exists everywhere.";
          }
        ];
      };
    };
  };
}
