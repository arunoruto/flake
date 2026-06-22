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

  # OpenCode-only: Zed has no first-class Fortran LSP adapter here, so Fortran is
  # left out of the Zed consumer (no consumerMeta.zed).
  consumerMeta.opencode = {
    extensions = [
      ".f90"
      ".f95"
      ".f03"
      ".f"
      ".for"
    ];
  };
}
