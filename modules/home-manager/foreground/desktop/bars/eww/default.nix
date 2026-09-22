# This flake's eww widgets, applied whenever home-manager's own
# `programs.eww.enable` is on -- there is no separate switch for them.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.eww.enable {
    programs.eww.package = lib.mkDefault pkgs.unstable.eww;

    # home-manager dropped `programs.eww.configDir` for single-file
    # `yuckConfig`/`scssConfig`, which cannot carry eww.scss's
    # `@import "./palette.scss"` or scripts/. Link the directory the way
    # configDir used to.
    xdg.configFile."eww".source = ./config;
  };
}
