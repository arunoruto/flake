{
  pkgs,
  lib,
  config,
  ...
}:
let
  flavor = "macchiato";
  catppuccin-swaylock = builtins.fetchGit {
    url = "https://github.com/catppuccin/swaylock";
    ref = "main";
  };
in
{
  options.sway.lock.enable = lib.mkEnableOption "Custom sway lock config";

  config = lib.mkIf config.sway.lock.enable {
    programs.swaylock = {
      enable = true;
    };
    # home.file.".config/swaylock/config".source = "${catppuccin-swaylock}/themes/macchiato.conf";
  };
}
