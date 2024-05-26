{
  programs.nixvim = {
    plugins = {
      lint = {
        enable = true;
        # https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file#available-linters
        lintersByFt = {
          python = ["ruff"];
          nix = ["deadnix" "nix"];
        };
        autoCmd = {
          callback = {
            __raw = ''
              function()
                require('lint').try_lint()
              end
            '';
          };
          event = ["BufEnter" "BufWritePost" "InsertLeave"];
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>l";
        action = ''function() require("lint").try_lint() end'';
        lua = true;
        options = {
          silent = true;
          desc = "Trigger linting for current file";
        };
      }
    ];
  };
}
