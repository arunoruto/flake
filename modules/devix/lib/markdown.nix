{ lib, pkgs }:

{
  lsps = {
    marksman = {
      enable = true;
      package = pkgs.marksman;
      command = lib.getExe pkgs.marksman;
    };

    markdown-oxide = {
      enable = true;
      package = pkgs.markdown-oxide;
      command = "markdown-oxide";
    };

    iwe = {
      enable = true;
      package = pkgs.iwe;
      command = "iwes";
    };
  };

  formatters.prettier-markdown = {
    enable = true;
    package = pkgs.prettier;
    command = "prettier";
    args = [ "--parser" "markdown" ];
  };

  language = {
    lspServers = [ "marksman" "markdown-oxide" "iwe" ];
    formatters = [ "prettier-markdown" ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
