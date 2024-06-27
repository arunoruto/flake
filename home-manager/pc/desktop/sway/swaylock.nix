{pkgs, ...}: let
  flavor = "macchiato";
  catppuccin-swaylock = builtins.fetchGit {
    url = "https://github.com/catppuccin/swaylock";
    ref = "main";
  };
in {
  programs.swaylock = {
    enable = true;
  };
  # home.file.".config/swaylock/config".source = "${catppuccin-swaylock}/themes/macchiato.conf";
}
