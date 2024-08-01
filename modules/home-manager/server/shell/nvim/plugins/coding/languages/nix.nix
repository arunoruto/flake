{inputs, ...}: {
  nixpkgs.overlays = [
    inputs.nil.overlays.nil
  ];

  programs.nixvim = {
    plugins = {
      lsp = {
        servers = {
          nil-ls.enable = true;
          # nixd.enable = true;
        };
      };
      none-ls = {
        sources = {
          code_actions = {
            statix.enable = true;
          };
          diagnostics = {
            statix.enable = true;
          };
          formatting = {
            alejandra.enable = true;
          };
        };
      };
    };
  };
}
