{
  config,
  pkgs,
  lib,
  ...
}:
let
  modifier = config.wayland.windowManager.sway.config.modifier;
  terminal = "wezterm";
  menu = "${pkgs.rofi}/bin/rofi -show drun";
  lockscreen = "${pkgs.swaylock}/bin/swaylock";
  left = "Left";
  right = "Right";
  up = "Up";
  down = "Down";

  #ws1 = "1:一";
  #ws2 = "2:二";
  #ws3 = "3:三";
  #ws4 = "4:四";
  #ws5 = "5:五";
  #ws6 = "6:六";
  #ws7 = "7:七";
  #ws8 = "8:八";
  #ws9 = "9:九";
  #ws0 = "10:十";

  ws1 = "number 1";
  ws2 = "number 2";
  ws3 = "number 3";
  ws4 = "number 4";
  ws5 = "number 5";
  ws6 = "number 6";
  ws7 = "number 7";
  ws8 = "number 8";
  ws9 = "number 9";
  ws0 = "number 10";
in
{
  options.sway.keybindings.enable = lib.mkEnableOption "Custom sway keybindings";

  config = lib.mkIf config.sway.keybindings.enable {
    wayland.windowManager.sway = {
      config = rec {
        defaultWorkspace = "workspace ${ws1}";
        keybindings = {
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+d" = "exec ${menu}";
          #"${modifier}+Shift+l" = "exec ${lockscreen}";

          "${modifier}+${left}" = "focus left";
          "${modifier}+${down}" = "focus down";
          "${modifier}+${up}" = "focus up";
          "${modifier}+${right}" = "focus right";

          "${modifier}+Shift+${left}" = "move left";
          "${modifier}+Shift+${down}" = "move down";
          "${modifier}+Shift+${up}" = "move up";
          "${modifier}+Shift+${right}" = "move right";

          "${modifier}+b" = "splith";
          "${modifier}+v" = "splitv";
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+a" = "focus parent";

          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";

          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";

          "${modifier}+1" = "workspace ${ws1}";
          "${modifier}+2" = "workspace ${ws2}";
          "${modifier}+3" = "workspace ${ws3}";
          "${modifier}+4" = "workspace ${ws4}";
          "${modifier}+5" = "workspace ${ws5}";
          "${modifier}+6" = "workspace ${ws6}";
          "${modifier}+7" = "workspace ${ws7}";
          "${modifier}+8" = "workspace ${ws8}";
          "${modifier}+9" = "workspace ${ws9}";
          "${modifier}+0" = "workspace ${ws0}";

          "${modifier}+Shift+1" = "move container to workspace ${ws1}";
          "${modifier}+Shift+2" = "move container to workspace ${ws2}";
          "${modifier}+Shift+3" = "move container to workspace ${ws3}";
          "${modifier}+Shift+4" = "move container to workspace ${ws4}";
          "${modifier}+Shift+5" = "move container to workspace ${ws5}";
          "${modifier}+Shift+6" = "move container to workspace ${ws6}";
          "${modifier}+Shift+7" = "move container to workspace ${ws7}";
          "${modifier}+Shift+8" = "move container to workspace ${ws8}";
          "${modifier}+Shift+9" = "move container to workspace ${ws9}";
          "${modifier}+Shift+0" = "move container to workspace ${ws0}";

          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";

          "${modifier}+Shift+r" = "reload";
          "${modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

          "${modifier}+r" = "mode resize";

          # Brightness
          "XF86MonBrightnessDown" = "exec light -U 5";
          "XF86MonBrightnessUp" = "exec light -A 5";

          # Volume
          "XF86AudioRaiseVolume" = "exec 'wpctl set-volume @DEFAULT_SINK@ 5%+ -l 1.0'";
          "XF86AudioLowerVolume" = "exec 'wpctl set-volume @DEFAULT_SINK@ 5%-'";
          "XF86AudioMute" = "exec 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'";

          # Media control
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioPause" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";

          # Screenshots
          "Print" = ''exec grim -g "$(slurp -d)" - | wl-copy'';
        };
      };
    };
  };
}
