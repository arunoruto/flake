{
  programs.nixvim = {
    plugins = {
      comment-nvim.enable = true;
      todo-comments.enable = true;
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>cn";
        action = ''function() require("todo-comments").jump_next() end'';
        lua = true;
        options = {
          silent = true;
          desc = "Next todo comment";
        };
      }
      {
        mode = "n";
        key = "<leader>cp";
        action = ''function() require("todo-comments").jump_prev() end'';
        lua = true;
        options = {
          silent = true;
          desc = "Previous todo comment";
        };
      }
      {
        mode = "n";
        key = "<leader>ft";
        action = "<cmd>TodoTelescope<CR>";
        options = {
          silent = true;
          desc = "Find TODOs";
        };
      }
    ];
  };
}
