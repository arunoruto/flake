{ lib, pkgs }:

{
  lsps.matlab-ls = {
    enable = true;
    package = pkgs.matlab-language-server;
    command = lib.getExe pkgs.matlab-language-server;
    args = [ "--stdio" ];
  };

  formatters = { };

  language = {
    lspServers = [ "matlab-ls" ];
    formatters = [ ];
    tabWidth = 4;
    insertSpaces = true;
  };

  # OpenCode-only: Zed has no first-class Matlab LSP adapter here, so Matlab is
  # left out of the Zed consumer (no consumerMeta.zed).
  consumerMeta.opencode = {
    extensions = [ ".m" ];
  };
}
