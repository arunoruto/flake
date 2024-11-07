{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.nixvim = {
    plugins = {
      lsp = {
        servers = {
          pyright.enable = true;
          ruff.enable = true;
        };
      };
      none-ls = {
        sources = {
          diagnostics = {
            pylint.enable = true;
          };
          formatting = {
            black = {
              enable = true;
              withArgs = ''
                {
                  extra_args = { "--fast" },
                }
              '';
            };
            isort.enable = true;
          };
        };
      };
      dap.extensions.dap-python = {
        enable = true;
        # package = pkgs.dap-python;
      };
    };
  };
}
