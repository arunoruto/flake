{
  config,
  lib,
  pkgs,
  ...
}: {
  options.bat.enable = lib.mkEnableOption "Enable cat rust alternative";

  config = lib.mkIf config.bat.enable {
    programs = {
      bat = {
        enable = true;
        config = {
          #paging = "never";
          #style = "plain";
          # theme = "Monokai Extended";
          #themes = "${catppuccin_bat}/Catppuccin-macchiato.tmTheme";
        };
        extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch];
      };

      zsh = {
        shellAliases = {
          cat = "bat --paging=never";
          less = "bat --paging=always";
        };
      };
    };
  };
}
