{pkgs, ...}: {
  home.packages = with pkgs; [
    playerctl
  ];

  programs.waybar = {
    settings = {
      mainBar = {
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
