{ lib, pkgs }:

{
  lsps.vscode-json-languageserver = {
    enable = true;
    command = "vscode-json-languageserver";
    args = [ "--stdio" ];
  };

  formatters.prettier-json = {
    enable = true;
    package = pkgs.prettier;
    command = "prettier";
    args = [ "--parser" "json" ];
  };

  language = {
    lspServers = [ "vscode-json-languageserver" ];
    formatters = [ "prettier-json" ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
