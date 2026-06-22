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
  # supported; pyright is registered, with Zed's defaults kept after it ("...").
  consumerMeta.zed = {
    name = "Python";
    extensions = [ ];
    languageServers = [
      "pyright"
      "..."
    ];
  };

  # OpenCode consumer metadata: file extensions handled by this language.
  consumerMeta.opencode = {
    extensions = [
      ".py"
      ".pyi"
    ];
  };
}
