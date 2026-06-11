{ lib, pkgs }:

{
  lsps.fortls = {
    enable = true;
    package = pkgs.fortls;
    command = lib.getExe pkgs.fortls;
  };

  formatters.fprettify = {
    enable = true;
    package = pkgs.fprettify;
    command = lib.getExe pkgs.fprettify;
  };

  language = {
    lspServers = [ "fortls" ];
    formatters = [ "fprettify" ];
    tabWidth = 4;
    insertSpaces = true;
  };
}
