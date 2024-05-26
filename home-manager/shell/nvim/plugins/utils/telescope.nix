{ ... }:
{
  programs.nixvim = {
    plugins = {
      telescope = {
        enable = true;

        defaults = {
          path_display = "smart";
          mappings = {
            i = {
              "<C-k>" = { __raw = "require('telescope.actions').move_selection_previous"; };
              "<C-j>" = { __raw = "require('telescope.actions').move_selection_next"; };
              "<C-q>" = { __raw = "require('telescope.actions').send_selected_to_qflist + require('telescope.actions').open_qflist"; };
            };
          };
        };
        extensions.fzf-native.enable = true;
        keymaps = {
          "<leader>ff" = { action = "find_files";   desc = "Fuzzy find files in cwd"; };
          "<leader>fr" = { action = "oldfiles";     desc = "Fuzzy find recent files"; };
          "<leader>fs" = { action = "live_grep";    desc = "Find string in cwd"; };
          "<leader>fc" = { action = "grep_string";  desc = "Find string under cursor in cwd"; };
        };
      };
    };
    #keymaps = [
    #  { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>";   options = { silent = true; desc = "Fuzzy find files in cwd "; }; }
    #  { mode = "n"; key = "<leader>fr"; action = "<cmd>Telescope oldfiles<CR>";     options = { silent = true; desc = "Fuzzy find recent files"; }; }
    #  { mode = "n"; key = "<leader>fs"; action = "<cmd>Telescope live_grep<CR>";    options = { silent = true; desc = "Find string in cwd"; }; }
    #  { mode = "n"; key = "<leader>fc"; action = "<cmd>Telescope grep_string<CR>";  options = { silent = true; desc = "Find string under cursor in cwd"; }; }
    #];
  };

}
