{pkgs, ...}: let
  image = "~/Pictures/wallpapers/anime/cafe-at-night.png";
  lockscreen = "${pkgs.swaylock}/bin/swaylock --image ${image}";
in {
  imports = [
    ./waybar
    ./services.nix
    ./theme.nix
    ./keybindings.nix
    # ./swaync.nix
    ./swaylock.nix
  ];
  wayland.windowManager.sway = {
    enable = true;
    # https://www.reddit.com/r/NixOS/comments/1c9n1qk/nixosrebuild_of_sway_failing_with_unable_to/
    checkConfig = false;
    config = rec {
      modifier = "Mod4";
      terminal = "wezterm";
      fonts = {
        names = ["FiraCode Nerd Font Mono"];
        style = "Regular";
        size = 10.0;
      };
      window = {
        border = 2;
        titlebar = false;
      };
      gaps = {
        inner = 8;
        outer = -5;
        smartBorders = "on";
        smartGaps = true;
      };
      input = {
        "type:keyboard" = {
          xkb_layout = "de";
          xkb_variant = "nodeadkeys";
        };
        "type:touchpad" = {
          click_method = "clickfinger";
          left_handed = "disabled";
          tap = "enabled";
          natural_scroll = "enabled";
          dwt = "enabled";
          accel_profile = "flat";
          pointer_accel = "0.25";
        };
      };
      output = {
        "*" = {
          # bg = "${image} fill";
          scale = "1.25";
        };
      };
      keybindings = {
        "${modifier}+Shift+l" = "exec ${lockscreen}";
      };
      bars = [
        {
          position = "top";
          mode = "dock";
          hiddenState = "hide";
          command = "${pkgs.waybar}/bin/waybar";
          #command = "${pkgs.sway}/bin/swaybar";
          #statusCommand = "${pkgs.i3status}/bin/i3status";
          workspaceButtons = true;
          workspaceNumbers = false;
          trayOutput = "primary";
          fonts = {
            names = ["FiraCode Nerd Font Mono"];
            style = "Regular";
            size = 11.0;
          };
        }
      ];
    };
  };
}
