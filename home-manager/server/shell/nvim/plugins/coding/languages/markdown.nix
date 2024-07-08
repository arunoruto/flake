{
  programs.nixvim = {
    plugins = {
      lsp = {
        servers = {
          marksman.enable = true;
        };
      };
      none-ls = {
        sources = {
          diagnostics = {
            # markdownlint_cli2.enable = true;
            markdownlint.enable = true;
          };
          formatting = {
            # markdownlint.enable = true;
            prettierd.enable = true;
          };
        };
      };
    };
  };
}
