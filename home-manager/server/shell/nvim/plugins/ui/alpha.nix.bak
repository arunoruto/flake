{
  programs.nixvim = {
    plugins = {
      alpha = {
        enable = true;
        iconsEnabled = false;

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
                shortcut = "e";
                desc = "  > New File";
                command = "<cmd>ene <cr>";
              }
              {
                shortcut = "SPC ee";
                desc = "  > Toggle file explorer";
                command = "<cmd>NvimTreeToggle<CR>";
              }
              {
                shortcut = "SPC ff";
                desc = "󰱼  > Find File";
                command = "<cmd>Telescope find_files<CR>";
              }
              {
                shortcut = "SPC fs";
                desc = "  > Find Word";
                command = "<cmd>Telescope live_grep<CR>";
              }
              {
                shortcut = "SPC wr";
                desc = "󰁯  > Restore Session For Current Directory";
                command = "<cmd>SessionRestore<CR>";
              }
              {
                shortcut = "SPC q";
                desc = "  > Quit NVIM";
                command = ":qa<cr>";
              }

              # {
              #   on_press = {
              #     __raw = "function() vim.cmd[[ene]] end";
              #   };
              #   opts = {
              #     shortcut = "n";
              #   };
              #   type = "button";
              #   val = "  New file";
              # }
              # {
              #   on_press = {
              #     __raw = "function() vim.cmd[[qa]] end";
              #   };
              #   opts = {
              #     shortcut = "q";
              #   };
              #   type = "button";
              #   val = " Quit Neovim";
              # }
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
