{pkgs, ...}: let
  #flavour = "macchiato";
  catppuccin-bat = "";
  #catppuccin-bat = builtins.fetchGit {
  #  url = "https://github.com/catppuccin/bat";
  #  ref = "main";
  #};
in {
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

  #home.file.".config/bat/themes/catppuccin" = {
  #  recursive = true;
  #  source = "${catppuccin-bat}";
  #};
}
