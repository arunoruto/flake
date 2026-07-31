{ lib, pkgs }:

{
  lsps = { };

  formatters.shfmt = {
    enable = true;
    package = pkgs.shfmt;
    command = "shfmt";
    args = [ ];
  };

  language = {
    lspServers = [ ];
    formatters = [ "shfmt" ];
    tabWidth = 2;
    insertSpaces = true;
  };

  # Zed treats Bash as "Shell Script"; it uses its own default servers ("...").
  consumerMeta.zed = {
    name = "Shell Script";
    extensions = [ ];
    languageServers = [ "..." ];
  };

  consumerMeta.opencode = {
    extensions = [
      ".sh"
      ".bash"
    ];
  };
}
