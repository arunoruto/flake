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

  # Nu has no devix LSP; Zed uses its own default servers ("...").
  consumerMeta.zed = {
    name = "Nu";
    extensions = [ "nu" ];
    languageServers = [ "..." ];
  };

  consumerMeta.opencode = {
    extensions = [ ".nu" ];
  };
}
