{ lib, pkgs }:

{
  lsps = { };

  formatters.nufmt = {
    enable = true;
    package = pkgs.nufmt;
    command = "nufmt";
    args = [ ];
  };

  language = {
    lspServers = [ ];
    formatters = [ "nufmt" ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
