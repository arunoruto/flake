{pkgs, ...}: let
  flavor = "macchiato";
  catppuccin-waybar = "";
  # catppuccin-waybar = builtins.fetchGit {
  #   url = "https://github.com/catppuccin/waybar";
  #   ref = "main";
  # };
in {
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

        "custom/spotify" = {
          format = "{icon} {}";
          format-icons = {
            Playing = " ";
            Paused = " ";
          };
          #escape = true;
          return-type = "json";
          #max-length = 40;
          interval = 30; # Remove this if your script is endless and write in loop
          on-click = "playerctl -p spotify play-pause";
          on-click-right = "killall spotify";
          smooth-scrolling-threshold = 10; # This value was tested using a trackpad, it should be lowered if using a mouse.
          on-scroll-up = "playerctl -p spotify next";
          on-scroll-down = "playerctl -p spotify previous";
          exec = "$HOME/.config/waybar/spotify.sh -a 2> /dev/null"; # Script in resources/custom_modules folder
          #exec-if = "pgrep spotify";
        };
      };
    };

    style = ''
      @import "catppuccin/${flavor}.css";

      * {
        font-family: FiraCode Nerd Font;
        font-size: 17px;
        min-height: 0;

      }

      #waybar {
        background: transparent;
        color: @text;
        margin: 5px 5px;
      }

      #workspaces {
        border-radius: 1rem;
        margin: 5px;
        background-color: @surface0;
        margin-left: 1rem;
      }

      #workspaces button {
        color: @blue;
        border-radius: 1rem;
        padding: 0.4rem;
      }

      #workspaces button.focused {
        color: @green;
        background: @base;
        border-radius: 1rem;
      }

      #workspaces button.urgent {
        color: @red;
        background: @crust;
        border-radius: 1rem;
      }

      #workspaces button:hover {
        color: @sapphire;
        background: @surface1;
        border-radius: 1rem;
      }

      #mode {
        color: @blue;
        border-radius: 1rem;
        padding: 0.4rem;
        margin: 5px;
        background-color: @surface0;
      }

      #window {
        border-radius: 1rem;
        margin: 5px;
        padding: 0.5rem 1rem;
        background-color: @surface0;
      }

      #pulseaudio,
      #network,
      #cpu,
      #memory,
      #temperature,
      #backlight,
      #battery,
      #clock,
      #tray,
      #custom-spotify,
      #custom-lock,
      #custom-power {
        background-color: @surface0;
        padding: 0.5rem 1rem;
        margin: 5px 0;
      }

      #clock {
        color: @blue;
        border-radius: 0px 1rem 1rem 0px;
        margin-right: 1rem;
      }

      #network      { color: @rosewater; }
      #cpu          { color: @teal; }
      #memory       { color: @peach; }
      #temperature  { color: @mauve; }
      #battery      { color: @green; }

      #battery.charging { color: @yellow; }
      #battery.warning:not(.charging) { color: @red; }

      #backlight {
        color: @yellow;
      }

      #backlight, #battery {
          border-radius: 0;
      }

      #pulseaudio {
        color: @maroon;
        border-radius: 1rem 0px 0px 1rem;
        margin-left: 1rem;
      }

      #custom-lock {
          border-radius: 1rem 0px 0px 1rem;
          color: @lavender;
      }

      #custom-power {
          margin-right: 1rem;
          border-radius: 0px 1rem 1rem 0px;
          color: @red;
      }

      #tray {
        margin-right: 1rem;
        border-radius: 1rem;
      }
    '';
  };
  # home.file.".config/waybar/catppuccin" = {
  #   recursive = true;
  #   source = "${catppuccin-waybar}/themes";
  # };
  home.file.".config/waybar/spotify.sh" = {
    text = ''
      #!/bin/sh

      player="spotify"

      artist () {
        player_status=$(playerctl -p $player status 2> /dev/null)
        if [ -z $player_status ]
        then
          exit
        fi
        text="$(playerctl -p $player metadata artist) - $(playerctl -p $player metadata title)"
        alt="$player_status"
        tooltip="$text"
        percentage=1
        echo "{\"text\": \"$text\", \"alt\": \"$alt\", \"tooltip\": \"$tooltip\", \"class\": \"$class\", \"percentage\": $percentage }"
      }

      cover () {
        cover_url=$(playerctl -p $player metadata mpris:artUrl 2> /dev/null)
        if [[ -z $cover_url ]]
        then
           # spotify is dead, we should die too.
           exit
        fi
        tooltip="$(playerctl -p $player metadata artist) - $(playerctl -p $player metadata title)"
        curl -s "$cover_url" --output "/tmp/cover.jpeg"
        echo "/tmp/cover.jpeg"
        #echo "/tmp/cover.jpeg\n$tooltip"
      }


      while [[ $# -gt 0 ]]; do
        case $1 in
          -a|--artist)
            artist
            shift # past argument
            ;;
          -c|--cover)
            cover
            shift # past argument
            ;;
          --default)
            DEFAULT=YES
            shift # past argument
            ;;
          -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
          *)
            #POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
        esac
      done
    '';
    executable = true;
  };
}
