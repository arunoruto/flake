{ lib, pkgs }:

{
  lsps.rust-analyzer = {
    enable = true;
    package = pkgs.rust-analyzer;
    command = lib.getExe pkgs.rust-analyzer;
  };

  formatters.rustfmt = {
    enable = true;
    package = pkgs.rustfmt;
    command = lib.getExe pkgs.rustfmt;
    args = [ ];
  };

  language = {
    lspServers = [ "rust-analyzer" ];
    formatters = [ "rustfmt" ];
    tabWidth = 4;
    insertSpaces = true;
  };

  consumerMeta.zed = {
    name = "Rust";
    extensions = [ ];
    languageServers = [
      "rust-analyzer"
      "..."
    ];
  };

  consumerMeta.opencode = {
    extensions = [ ".rs" ];
  };
}
