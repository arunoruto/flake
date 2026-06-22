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

  # OpenCode-only: Zed has no first-class Julia LSP adapter here, so Julia is
  # left out of the Zed consumer (no consumerMeta.zed).
  consumerMeta.opencode = {
    extensions = [ ".jl" ];
  };
}
