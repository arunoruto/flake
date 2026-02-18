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
  cfg = config.programs.bat;
  batExe = lib.getExe cfg.package;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
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

      fish.shellAbbrs."--help" = {
        position = "anywhere";
        expansion = "--help | ${batExe} -plhelp";
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

    home.sessionVariables.MANPAGER = "${batExe} -plman";
  };
}
