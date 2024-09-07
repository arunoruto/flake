{
  config,
  lib,
  pkgs,
  ...
}: {
  options.bars.eww.enable = lib.mkEnableOption "Enable eww bar";

  config = lib.mkIf config.bars.eww.enable {
    programs.eww = {
      enable = true;
      package = pkgs.unstable.eww;
      # enableZshIntegration = true;
      # configDir = "~/.config/eww";
      # configDir = config.home.homeDirectory + "/.config/eww";
      configDir = ./config;
    };
  };
}
