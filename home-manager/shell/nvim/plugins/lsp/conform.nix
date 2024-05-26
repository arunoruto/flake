{
  programs.nixvim = {
    plugins = {
      conform-nvim = {
        enable = true;
        # https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters
        formattersByFt = {
          css = [["prettierd" "prettier"]];
          html = [["prettierd" "prettier"]];
          lua = ["stylua"];
          markdown = [["prettierd" "prettier"]];
          nix = ["alejandra"];
          python = ["ruff_fix" "ruff_format"];
          json = ["yq" ];
          yaml = ["yamllint" "yamlfmt" "yq"];
          "_" = ["trim_whitespace"];
        };
        formatOnSave = {
          lspFallback = true;
          timeoutMs = 500;
        };
        notifyOnError = true;
      };
    };
    keymaps = [
      {
        mode = ["n" "v"];
        key = "<leader>mp";
        action = ''function() require("conform").format({lsp_fallback = true, async = false, timeout_ms = 1000}) end'';
        lua = true;
        options = {
          silent = true;
          desc = "Format file or range (in visual mode)";
        };
      }
    ];
  };
}
