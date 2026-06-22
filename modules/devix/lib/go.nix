{ lib, pkgs }:

{
  lsps = {
    gopls = {
      enable = true;
      package = pkgs.gopls;
      command = lib.getExe pkgs.gopls;
    };

    golangci-lint-langserver = {
      enable = true;
      package = pkgs.golangci-lint-langserver;
      command = "golangci-lint-langserver";
    };
  };

  formatters.gofmt = {
    enable = true;
    package = pkgs.go;
    command = lib.getExe' pkgs.go "gofmt";
    args = [ ];
  };

  language = {
    lspServers = [
      "gopls"
      "golangci-lint-langserver"
    ];
    formatters = [ "gofmt" ];
    tabWidth = 4;
    insertSpaces = true;
  };

  # Zed uses gopls (then its defaults); golangci-lint-langserver is Helix/
  # OpenCode-only and is intentionally not surfaced to Zed.
  consumerMeta.zed = {
    name = "Go";
    extensions = [ ];
    languageServers = [
      "gopls"
      "..."
    ];
  };

  consumerMeta.opencode = {
    extensions = [ ".go" ];
  };
}
