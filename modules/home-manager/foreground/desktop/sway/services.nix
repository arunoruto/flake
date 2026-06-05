{
  pkgs,
  lib,
  config,
  ...
}:
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
