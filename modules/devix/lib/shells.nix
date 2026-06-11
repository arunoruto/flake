{ lib, pkgs }:

{
  lsps.fish-lsp = {
    enable = true;
    package = pkgs.fish-lsp;
    command = "fish-lsp";
    args = [ "start" ];
  };

  formatters = { };

  language = {
    lspServers = [ "fish-lsp" ];
    formatters = [ ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
