{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.dev;
in
{
  programs.dev.languages.go = {
    extensions = [ ".go" ];
    autoFormat = true;
    lspServers = [
      "gopls"
      "golangci-lint-langserver"
    ]
    ++ lib.optionals cfg.lsp.servers.codebook.enable [ "codebook" ];

    formatter = {
      package = pkgs.go;
      command = lib.getExe' pkgs.go "gofmt";
      args = [ ];
    };

    helix.languageConfig.indent = {
      tab-width = 4;
      unit = " ";
    };

    packages = with pkgs; [
      delve
      go
      golangci-lint
      golangci-lint-langserver
      gopls
    ];
  };
}
