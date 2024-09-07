{
  lib,
  config,
  ...
}: {
  imports = [
    # ./custom/spotify.nix
  ];

  options.bars.waybar.enable = lib.mkEnableOption "Enable waybar config";

  config = lib.mkIf config.bars.waybar.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          #spacing = 4;

          modules-left = [
            "sway/workspaces"
            "sway/mode"
            "hyprland/workspaces"
            "image#cover-art"
            "custom/spotify"
            #"sway/scratchpad"
            #"custom/media"
          ];
          #modules-center = [ "sway/window" ];
          modules-right = [
            #"image#padding-left"
            "pulseaudio"
            "network"
            #"cpu"
            #"memory"
            #"temperature"
            "backlight"
            "battery"
            "clock"
            "tray"
          ];

          #"image#padding-left" = {
          #	#"path": "/tmp/mpd_art",
          #	size = 32;
          #	#"interval": 5,
          #	#"on-click": "mpc toggle"
          #};

          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            warp-on-scroll = false;
            #format = "{name}: {icon}";
            format = "{icon}";
            format-icons = {
              "1" = "一";
              "2" = "二";
              "3" = "三";
              "4" = "四";
              "5" = "五";
              "6" = "六";
              "7" = "七";
              "8" = "八";
              "9" = "九";
              "10" = "十";
              "urgent" = "";
              #"focused" = "";
              "default" = "";
            };
          };

          "sway/mode" = {
            format = "{}";
            max-length = 50;
          };

          "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            warp-on-scroll = false;
            format = "{icon}";
            format-icons = {
              "1" = "一";
              "2" = "二";
              "3" = "三";
              "4" = "四";
              "5" = "五";
              "6" = "六";
              "7" = "七";
              "8" = "八";
              "9" = "九";
              "10" = "十";
              "urgent" = "";
              #"focused" = "";
              "default" = "";
            };
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };

          pulseaudio = {
            format = "{icon} {volume:3}%";
            format-bluetooth = "{icon} {volume}% ";
            format-muted = "󰖁   0%";
            format-icons = {
              headphone = "";
              default = ["󰕿 " "󰖀 " "󰕾 "];
            };
            scroll-step = 5;
            on-click = "pavucontrol";
            ignored-sinks = ["Easy Effects Sink"];
          };

          network = {
            #interface = "wlp2s0";
            format = "{ifname}";
            format-wifi = " ";
            format-ethernet = "{ipaddr}/{cidr} 󰊗 ";
            format-disconnected = "";
            tooltip-format = "{ifname} via {gwaddr} 󰊗 ";
            tooltip-format-wifi = "{essid} ({signalStrength}%)";
            tooltip-format-ethernet = "{ifname}  ";
            tooltip-format-disconnected = "Disconnected";
            #max-length = 50;
          };

          cpu = {
            interval = 10;
            format = " {usage}%";
            #max-length = 10;
          };

          memory = {
            interval = 30;
            format = " {percentage}%";
            #max-length = 10;
          };

          temperature = {
            #"thermal-zone": 2,
            #"hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
            #"critical-threshold": 80,
            format = " {temperatureC}°C";
            format-critical = " {temperatureC}°C";
          };

          backlight = {
            format = "{icon} {percent}%";
            format-icons = [" " "󰃟 " "󰃠 "];
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            #format-icons = [" " " " " " " " " "];
            format-icons = ["󰂎" "󰁻" "󰁾" "󰂁" "󰁹"];
          };

          "image#cover-art" = {
            exec = "$HOME/.config/waybar/spotify.sh -c 2> /dev/null";
            size = 32;
            interval = 30;
            tooltip = true;
          };
        };
      };
      style = builtins.readFile ./style.css;
    };
  };
}
