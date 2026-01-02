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
  programs.dev.languages.typst = {
    extensions = [ ".typ" ];
    autoFormat = true;
    lspServers = (lib.optionals cfg.lsp.servers.ltex.enable [ "ltex" ]) ++ [ "tinymist" ];

    formatter = {
      package = pkgs.typstyle;
      command = lib.getExe pkgs.typstyle;
    };

    helix.languageConfig = {
      rulers = [ 120 ];
      soft-wrap.enable = true;
    };

    packages = with pkgs; [
      tinymist
      typstyle
    ];
  };
}
