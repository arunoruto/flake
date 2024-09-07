# Docs: https://github.com/outfoxxed/hy3
{
  pkgs,
  lib,
  config,
  ...
}: {
  options.hypr.plugins.hy3.enable = lib.mkEnableOption "Use i3 layour in hyprland";

  config = lib.mkIf config.hypr.plugins.hy3.enable {
    wayland.windowManager.hyprland = {
      settings = {
        general.layout = "hy3";
        bind = [
          "$mod, V, hy3:makegroup, opposite"
          # "$mod, V, hy3:changegroup, opposite"
        ];
        plugin = {
          h3 = {
            no_gaps_when_only = 1;
          };
        };
      };
      plugins = [
        pkgs.hyprlandPlugins.hy3
      ];
    };
  };
}
