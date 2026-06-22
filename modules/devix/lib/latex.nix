{ lib, pkgs }:

{
  lsps.texlab = {
    enable = true;
    package = pkgs.texlab;
    command = lib.getExe pkgs.texlab;
  };

  formatters = { };

  language = {
    lspServers = [ "texlab" ];
    formatters = [ ];
    tabWidth = 2;
    insertSpaces = true;
  };

  consumerMeta.zed = {
    name = "LaTeX";
    extensions = [ "latex" ];
    languageServers = [
      "texlab"
      "..."
    ];
  };

  consumerMeta.opencode = {
    extensions = [
      ".tex"
      ".sty"
      ".cls"
    ];
  };
}
