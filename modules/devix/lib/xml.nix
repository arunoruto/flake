{ lib, pkgs }:

{
  lsps.lemminx = {
    enable = true;
    package = pkgs.lemminx;
    command = "lemminx";
  };

  formatters = { };

  language = {
    lspServers = [ "lemminx" ];
    formatters = [ ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
