{ lib, pkgs }:

{
  lsps.yaml-lsp = {
    enable = true;
    package = pkgs.yaml-language-server;
    command = lib.getExe pkgs.yaml-language-server;
    args = [ "--stdio" ];
  };

  formatters.yamlfmt = {
    enable = true;
    package = pkgs.yamlfmt;
    command = "yamlfmt";
    args = [ "-" ];
  };

  language = {
    lspServers = [ "yaml-lsp" ];
    formatters = [ "yamlfmt" ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
