{ lib, pkgs }:

{
  lsps.fish-lsp = {
    enable = true;
    package = pkgs.fish-lsp;
    command = "fish-lsp";
    args = [ "start" ];
  };

  formatters.fish-indent = {
    enable = true;
    package = pkgs.fish;
    command = "fish_indent";
    args = [ ];
  };

  language = {
    lspServers = [ "fish-lsp" ];
    formatters = [ "fish-indent" ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
