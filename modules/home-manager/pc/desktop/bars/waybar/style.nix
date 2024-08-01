{pkgs, ...}: let
  flavor = "macchiato";
  catppuccin-waybar = "";
  # catppuccin-waybar = builtins.fetchGit {
  #   url = "https://github.com/catppuccin/waybar";
  #   ref = "main";
  # };
in {
  programs.waybar = {
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
}
