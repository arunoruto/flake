{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.sway.lock.enable = lib.mkEnableOption "Custom sway lock config";

  config = lib.mkIf config.sway.lock.enable {
    programs.swaylock = {
      enable = true;
    };
    # home.file.".config/swaylock/config".source = "${catppuccin-swaylock}/themes/macchiato.conf";
  };
}
