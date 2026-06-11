{ lib, pkgs }:

{
  lsps.texlab = {
    enable = true;
    package = pkgs.texlab;
    command = lib.getExe pkgs.texlab;
  };

  formatters = { };

  language = {
    lspServers = [ "texlab" ];
    formatters = [ ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
