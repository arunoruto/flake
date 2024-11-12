{
  config,
  pkgs,
  lib,
  ...
}:
let
  terminal = "wezterm";
  menu = "${pkgs.wofi}/bin/wofi --show drun --normal-window";

  # left = "left";
  # right = "right";
  # up = "up";
  # down = "down";
  left = "H";
  right = "L";
  up = "K";
  down = "J";
in
{
  options.hypr.binds.enable = lib.mkEnableOption "Custom hyprland keybindings";

  config = lib.mkIf config.hypr.binds.enable {
    wayland.windowManager.hyprland.settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, Return, exec, ${terminal}"
        "$mod, SPACE, togglefloating"
        "$mod, D, exec, ${menu}"
        "$mod, F, fullscreen"

        "$mod SHIFT, Q, killactive"
        "$mod SHIFT, E, exit"
        "$mod SHIFT, R, exec, hyprctl reload"
        # "$mod SHIFT, R, exec, ${pkgs.hyprland}/bin/hyprctl reload"

        # Move focus with mod + arrow keys
        "$mod, ${left},  movefocus, l"
        "$mod, ${right}, movefocus, r"
        "$mod, ${up},    movefocus, u"
        "$mod, ${down},  movefocus, d"

        # Move focused window with mod + shift + arrow keys
        "$mod SHIFT, ${left},  movewindow, l"
        "$mod SHIFT, ${right}, movewindow, r"
        "$mod SHIFT, ${up},    movewindow, u"
        "$mod SHIFT, ${down},  movewindow, d"

        # Switch workspace with mod + [0-9]
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to a workspace with mod + shift + [0-9]
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Example special workspace (scratchpad)
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspace with mod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up,   workspace, e-1"

        # Brightness
        ",XF86MonBrightnessDown, exec, light -U 5"
        ",XF86MonBrightnessUp,   exec, light -A 5"

        # Volume
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        # Media
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        # Screenshot
        # '', Print, exec, grim -g "$(slurp -d)" - | wl-copy''
        ", Print, exec, ${lib.getExe pkgs.hyprshot} --clipboard-only -m region"

        # Shortcuts
        # "$mod, F1, exec, \${BROWSER}"
        # "$mod, F1, exec, google-chrome-stable"
        # "$mod, F1, exec, firefox"
        "$mod, F1, exec, ${config.home.sessionVariables.BROWSER}"
      ];

      bindm = [
        # Move/resize windows with mod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
