{ lib, pkgs }:

{
  description = "AI completion language servers";

  lsps = {
    copilot = {
      enable = true;
      package = pkgs.copilot-language-server;
      args = [ "--stdio" ];
    };

    lsp-ai = {
      enable = true;
      package = pkgs.lsp-ai;
      args = [ "--use-seperate-log-file" ];
    };
  };

  # Both are attached when the addon is on; narrow this to one in policy if you
  # do not want two completion sources competing.
  lspServers = [
    "copilot"
    "lsp-ai"
  ];

  # AI completion is not language-specific.
  languages = [ "*" ];
}
