{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./binds.nix
    ./plugins
    #  ./services.nix
    #  ./theme.nix
    #  ./waybar
    ./wallpaper.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # monitor = ",preferred,auto,1.175";
      monitor = lib.mkDefault ",preferred,auto,1";

      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 3;
        gaps_out = 5;
        border_size = 2;
        # "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        # "col.inactive_border" = "rgba(595959aa)";

        layout = lib.mkDefault "dwindle";

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };

      decoration = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        rounding = 10;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
        };

        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        # "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = true;

        # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      input = {
        kb_layout = "de";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = true;
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };

      exec-once = [
        "ags"
        # "waybar"
        # ''mpvpaper -o "no-audio --loop-playlist --video-aspect-override=3:2" '*' $HOME/Videos/TBATE_AnimDesktop_Vol08.mp4''
        # ''mpvpaper -o "no-audio --loop-playlist panscan=1.0 '*' $HOME/Videos/TBATE_AnimDesktop_Vol08.mp4''
      ];

      workspace = [
        "1, defautName:0"
        "2, defautName:1"
        "3, defautName:2"
        "4, defautName:3"
        "5, defautName:4"
        "6, defautName:5"
        "7, defautName:6"
        "8, defautName:7"
        "9, defautName:8"
        "10,defautName:9"
      ];
    };
    xwayland = {
      enable = true;
    };
    extraConfig = ''
      xwayland {
        force_zero_scaling = true
      }
    '';
  };

  home.packages = with pkgs; [
    hyprshot
    #   wofi
    #   mpvpaper
  ];
}
