{
  config,
  pkgs,
  ...
}: let
  pkg = pkgs.unstable.hyprlock;
  font = config.stylix.fonts.monospace.name;
in {
  programs.hyprlock = {
    enable = true;
    package = pkg;
    settings = {
      general = {
        no_fade_in = false;
        grace = 0;
        disable_loading_bar = true;
        # pam = "gdm-fingerprint";
      };
      background = {
        monitor = "";
        path = config.stylix.image;
        blur_passes = 1;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      };
      input-field = {
        monitor = "";
        size = "400, 60";
        outline_thickness = 2;
        dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = true;
        outer_color = "rgba(0, 0, 0, 0)";
        inner_color = "rgba(0, 0, 0, 0.5)";
        font_color = "rgb(200, 200, 200)";
        fade_on_empty = false;
        # font_family = font;
        placeholder_text = ''<i><span foreground="##cdd6f4">Input Password...</span></i>'';
        hide_input = false;
        position = "0, -120";
        halign = "center";
        valign = "center";
      };
      label = [
        {
          monitor = "";
          # text = ''cmd[update:1000] echo "$(date +"%-I:%M%p")"'';
          text = "$TIME";
          # color = "$foreground";
          color = "rgba(255, 255, 255, 0.6)";
          font_size = 120;
          font_family = font;
          position = "0, -300";
          halign = "center";
          valign = "top";
        }
        {
          monitor = "";
          text = "Hi there, $USER";
          # color = "$foreground";
          color = "rgba(255, 255, 255, 0.6)";
          font_size = 25;
          font_family = font;
          position = "0, -40";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] playerctl metadata --format '{{title}}  {{artist}}'";
          # color = "$foreground";
          color = "rgba(255, 255, 255, 0.6)";
          font_size = 18;
          font_family = font;
          position = "0, 20";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };

  wayland.windowManager.hyprland.settings.bind = [
    "SHIFT ALT, L, exec, ${pkg}/bin/hyprlock"
    # "$mod SHIFT, L, exec, ${pkg}"
  ];
}
