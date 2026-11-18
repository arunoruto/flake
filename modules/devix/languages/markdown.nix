{ lib, pkgs }:

{
  lsps = {
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
    args = [
      "--parser"
      "markdown"
    ];
  };

  language = {
    lspServers = [
      "markdown-oxide"
      "iwe"
    ];
    formatters = [ "prettier-markdown" ];
    tabWidth = 2;
    insertSpaces = true;
  };

  # The devix markdown LSPs (markdown-oxide/iwe) are Helix/OpenCode-only;
  # Zed uses its own default Markdown servers ("...").
  consumerMeta.zed = {
    name = "Markdown";
    extensions = [ ];
    languageServers = [ "..." ];
  };

  consumerMeta.opencode = {
    extensions = [
      ".md"
      ".markdown"
    ];
  };
}
