# Docs: https://github.com/outfoxxed/hy3
{pkgs, ...}: {
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
}
