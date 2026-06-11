{ lib, pkgs }:

{
  lsps.julia-ls = {
    enable = true;
    package = pkgs.julia;
    command = lib.getExe pkgs.julia;
    args = [
      "--startup-file=no"
      "--history-file=no"
      "--thread=auto"
      "-e"
      "using LanguageServer; runserver();"
    ];
  };

  formatters = { };

  language = {
    lspServers = [ "julia-ls" ];
    formatters = [ ];
    tabWidth = 4;
    insertSpaces = true;
  };
}
