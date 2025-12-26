{ pkgs, lib, config, ... }:
let
  cfg = config.programs.dev;
in
{
  programs.dev.languages.latex = {
    extensions = [ ".tex" ];
    autoFormat = true;
    lspServers =
      [ "texlab" ]
      ++ lib.optionals cfg.lsp.servers.ltex.enable [ "ltex" ];

    packages = with pkgs; [ texlab ];
  };
}
