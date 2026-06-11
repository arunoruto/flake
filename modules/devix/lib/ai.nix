{ lib, pkgs }:

{
  lsps = {
    copilot = {
      enable = true;
      package = pkgs.unstable.copilot-language-server;
      command = "copilot-language-server";
      args = [ "--stdio" ];
    };

    lsp-ai = {
      enable = true;
      package = pkgs.lsp-ai;
      command = lib.getExe pkgs.lsp-ai;
      args = [ "--use-seperate-log-file" ];
    };
  };

  formatters = { };

  language = {
    lspServers = [ "copilot" "lsp-ai" ];
    formatters = [ ];
    tabWidth = 4;
    insertSpaces = true;
  };
}
