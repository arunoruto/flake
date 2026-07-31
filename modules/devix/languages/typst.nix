{ lib, pkgs }:

{
  lsps.tinymist = {
    enable = true;
    package = pkgs.tinymist;
    config = {
      preview.background.enabled = true;
      preview.background.args = [
        "--data-plane-host=127.0.0.1:23635"
        "--invert-colors=never"
        "--open"
      ];
    };
  };

  formatters.typstyle = {
    enable = true;
    package = pkgs.typstyle;
    command = "typstyle";
  };

  language = {
    lspServers = [ "tinymist" ];
    formatters = [ "typstyle" ];
    tabWidth = 2;
    insertSpaces = true;
  };

  consumerMeta.zed = {
    name = "Typst";
    extensions = [ "typst" ];
    languageServers = [
      "tinymist"
      "..."
    ];
  };

  consumerMeta.opencode = {
    extensions = [ ".typ" ];
  };
}
