{
  config,
  lib,
  pkgs,
  ...
}:
let
  shellAliases = {
    cat = "bat -pp";
    less = "bat --paging=always --wrap=never";
  };
in
{
  config = lib.mkIf config.programs.bat.enable {
    programs =
      {
        bat = {
          # config = {
          #   #paging = "never";
          #   #style = "plain";
          #   # theme = "Monokai Extended";
          #   #themes = "${catppuccin_bat}/Catppuccin-macchiato.tmTheme";
          # };
          extraPackages = with pkgs.bat-extras; [
            batdiff
            batman
            batgrep
            batwatch
          ];
        };
      }
      // {
        bash = {
          inherit shellAliases;
        };
        fish = {
          inherit shellAliases;
        };
        nushell = {
          inherit shellAliases;
        };
        zsh = {
          inherit shellAliases;
        };
      };
  };
}
