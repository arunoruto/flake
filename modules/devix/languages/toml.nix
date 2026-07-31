{ lib, pkgs }:

{
  lsps.taplo = {
    enable = true;
    package = pkgs.taplo;
    command = "taplo";
    args = [
      "lsp"
      "stdio"
    ];
  };

  formatters.taplo-fmt = {
    enable = true;
    package = pkgs.taplo;
    command = "taplo";
    args = [
      "fmt"
      "-"
    ];
  };

  language = {
    lspServers = [ "taplo" ];
    formatters = [ "taplo-fmt" ];
    tabWidth = 2;
    insertSpaces = true;
  };

  consumerMeta.zed = {
    name = "TOML";
    extensions = [ ];
    languageServers = [
      "taplo"
      "..."
    ];
  };

  consumerMeta.opencode = {
    extensions = [ ".toml" ];
  };
}
