{ pkgs, lib, config, ... }:
let
  cfg = config.programs.dev;
in
{
  programs.dev.languages.markdown = {
    extensions = [ ".md" ".markdown" ];
    autoFormat = true;
    lspServers =
      (lib.optionals cfg.lsp.servers.ltex.enable [ "ltex" ])
      ++ [
        "marksman"
        "oxide"
      ]
      ++ lib.optionals cfg.lsp.servers.copilot.enable [ "copilot" ]
      ++ lib.optionals cfg.lsp.servers.codebook.enable [ "codebook" ]
      ++ [ "iwe" ];

    formatter = {
      package = pkgs.nodePackages.prettier;
      command = lib.getExe pkgs.nodePackages.prettier;
      args = [ "--parser" "markdown" ];
    };

    helix.languageConfig = {
      rulers = [ 120 ];
      soft-wrap.enable = true;
    };

    packages = with pkgs; [
      iwe
      markdown-oxide
      marksman
      nodePackages.prettier
    ];
  };
}
