{
  programs.nixvim = {
    plugins = {
      comment.enable = true;
      todo-comments.enable = true;
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>cn";
        action.__raw = ''function() require("todo-comments").jump_next() end'';
        options = {
          silent = true;
          desc = "Next todo comment";
        };
      }
      {
        mode = "n";
        key = "<leader>cp";
        action.__raw = ''function() require("todo-comments").jump_prev() end'';
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
