{ lib, pkgs }:

{
  lsps.rust-analyzer = {
    enable = true;
    package = pkgs.rust-analyzer;
    command = "rust-analyzer";
    config = {
      # files.watcher = "server";
      cargo.sysrootSrc = "${pkgs.rustPlatform.rustLibSrc}";
    };
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
    roots = [
      "Cargo.toml"
      "Cargo.lock"
    ];
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

  packages = with pkgs; [
    rustc
    cargo
  ];
}
