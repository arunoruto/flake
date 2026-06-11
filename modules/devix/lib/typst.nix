{ lib, pkgs }:

{
  lsps.tinymist = {
    enable = true;
    package = pkgs.tinymist;
    command = lib.getExe pkgs.tinymist;
  };

  formatters.typstyle = {
    enable = true;
    package = pkgs.typstyle;
    command = "typstyle";
  };

  language = {
    lspServers = [ "tinymist" ];
    formatters = [ "typstyle" ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
