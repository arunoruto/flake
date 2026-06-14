{ lib, pkgs }:

{
  lsps = { };

  formatters.shfmt = {
    enable = true;
    package = pkgs.shfmt;
    command = "shfmt";
    args = [ ];
  };

  language = {
    lspServers = [ ];
    formatters = [ "shfmt" ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
