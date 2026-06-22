{ lib, pkgs }:

{
  lsps.pyright = {
    enable = true;
    package = pkgs.pyright;
    command = lib.getExe' pkgs.pyright "pyright-langserver";
    args = [ "--stdio" ];
    config.python.analysis.typeCheckingMode = "strict";
  };

  formatters = {
    ruff-check = {
      enable = true;
      package = pkgs.ruff;
      command = lib.getExe pkgs.ruff;
      args = [
        "check"
        "--select"
        "I"
        "--fix"
        "-"
      ];
    };

    ruff-format = {
      enable = true;
      package = pkgs.ruff;
      command = lib.getExe pkgs.ruff;
      args = [
        "format"
        "-"
      ];
    };
  };

  language = {
    lspServers = [ "pyright" ];
    formatters = [
      "ruff-check"
      "ruff-format"
    ];
    tabWidth = 4;
    insertSpaces = true;
  };

  # Zed consumer metadata. Presence of this block makes Zed treat Python as
  # supported; the devix LSP registry names (pyright) match Zed's adapter ids.
  consumerMeta.zed = {
    name = "Python";
    extensions = [ ];
    lspAdapters = { };
  };
}
