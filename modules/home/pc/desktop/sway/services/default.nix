{
  pkgs,
  lib,
  config,
  ...
}:
# let
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
  options.sway.services.enable = lib.mkEnableOption "Custom sway services";

  config = lib.mkIf config.sway.services.enable {
    programs.rofi = {
      enable = true;
    };

    # services.mako = {
    #   enable = true;
    #   defaultTimeout = 10000;
    #   # extraConfig = builtins.readFile "${catppuccin-mako}/src/${flavor}";
    # };

    #services.wob = {
    #  enable = true;
    #};
  };
}
