# {pkgs, ...}: let
#   flavor = "macchiato";
#   catppuccin-rofi = builtins.fetchGit {
#     url = "https://github.com/catppuccin/rofi";
#     ref = "main";
#   };
#   catppuccin-mako = builtins.fetchGit {
#     url = "https://github.com/catppuccin/mako";
#     ref = "main";
#   };
# in
{
  programs.rofi = {
    enable = true;
    # font = "FiraCode Nerd Font Mono 14";
    # theme = "${catppuccin-rofi}/basic/.local/share/rofi/themes/catppuccin-${flavor}.rasi";
  };

  services.mako = {
    enable = true;
    defaultTimeout = 10000;
    # extraConfig = builtins.readFile "${catppuccin-mako}/src/${flavor}";
  };

  #services.wob = {
  #  enable = true;
  #};
}
