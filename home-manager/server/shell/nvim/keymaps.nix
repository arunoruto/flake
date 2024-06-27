{ ... }:
{
 programs.nixvim = {
    #keymaps = helpers.keymaps.mkKeymaps {
    #  mode = "n";
    #  options.silent = true;
    #}
    keymaps = 
    [
      {
        mode = "i";
        key = "jk";
        action = "<ESC>";
        options.desc = "Exit insert mode with jk";
      }
      {
        action = ":bnext";
        key = "<leader>bl";
        options = {
          silent = true;
          desc = "Next buffer tab";
        };
      }
      {
        action = ":bprev";
        key = "<leader>bh";
        options = {
          silent = true;
          desc = "Previous buffer tab";
        };
      }
      # windows management
      { mode ="n"; key = "<leader>sv"; action = "<C-w>v"; options.desc = "Split window vertically"; }
      { mode ="n"; key = "<leader>sh"; action = "<C-w>s"; options.desc = "Split window horizontally"; }
      { mode ="n"; key = "<leader>se"; action = "<C-w>="; options.desc = "Make splits equal size"; }
      { mode ="n"; key = "<leader>sx"; action = "<cmd>close<CR>"; options.desc = "Close current split"; }
      # tab managements
      { mode ="n"; key = "<leader>to"; action = "<cmd>tabnew<CR>";        options.desc = "Open new tab"; }
      { mode ="n"; key = "<leader>tx"; action = "<cmd>tabclose<CR>";      options.desc = "Close current tab"; }
      { mode ="n"; key = "<leader>tn"; action = "<cmd>tabnext<CR>";      options.desc = "Go to next tab"; }
      { mode ="n"; key = "<leader>tp"; action = "<cmd>tabprevious<CR>";  options.desc = "Go to previous tab"; }
      { mode ="n"; key = "<leader>tf"; action = "<cmd>tabnew %<CR>";      options.desc = "Open current buffer in new tab"; }
    ];
  };
}
