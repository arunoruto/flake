{ ... }:
{
  programs.nixvim = {
    globals = {
      "loaded_netrw" = 1;
      "loaded_netrwPlugin" = 1;
    };
    plugins = {
      nvim-tree = {
        enable = true;
        view = {
          width = 35;
          relativenumber = true;
        };
        renderer = {
          indentMarkers.enable = true;
        };
        actions.windowPicker.enable = false;
        filters.custom = [ ".DS_Store" ];
        git = {
          enable = true;
          ignore = false;
        };
        diagnostics = {
          enable = true;
          icons = {
            hint = "";
            info = "";
            warning = "";
            error = "";
          };
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<C-n>";
        action = "<cmd>NvimTreeToggle<CR>";
        options = {
          silent = true;
          desc = "Toggle file explorer";
        };
      }
      {
        mode = "n";
        key = "<leader>ee";
        action = "<cmd>NvimTreeToggle<CR>";
        options = {
          silent = true;
          desc = "Toggle file explorer";
        };
      }
      {
        mode = "n";
        key = "<leader>er";
        action = "<cmd>NvimTreeRefresh<CR>";
        options = {
          silent = true;
          desc = "Refresh file explorer";
        };
      }
      {
        mode = "n";
        key = "<leader>ef";
        action = "<cmd>NvimTreeFindFileToggle<CR>";
        options = {
          silent = true;
          desc = "Toggle file exporer on current file";
        };
      }
      {
        mode = "n";
        key = "<leader>ec";
        action = "<cmd>NvimTreeCollapse<CR>";
        options = {
          silent = true;
          desc = "Collapse file exporer";
        };
      }
    ];
  };

}
