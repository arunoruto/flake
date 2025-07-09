{
  pkgs,
  lib,
  config,
  ...
}:
let
  image = "~/Pictures/wallpapers/anime/cafe-at-night.png";
  lockscreen = "${pkgs.swaylock}/bin/swaylock --image ${image}";
in
{
  imports = [
    ./services.nix
    # ./theme.nix
    ./keybindings.nix
    # ./swaync.nix
    ./swaylock.nix
  ];

  options.sway.enable = lib.mkEnableOption "Custom sway config";

  config = lib.mkIf config.wayland.windowManager.sway.enable {
    sway = {
      keybindings.enable = lib.mkDefault true;
      services.enable = lib.mkDefault true;
      lock.enable = lib.mkDefault true;
      # notify.enable = lib.mkDefault true;
    };

    wayland.windowManager.sway = {
      # https://www.reddit.com/r/NixOS/comments/1c9n1qk/nixosrebuild_of_sway_failing_with_unable_to/
      checkConfig = false;
      config = rec {
        modifier = "Mod4";
        terminal = "wezterm";
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
              names = [ config.stylix.fonts.sansSerif.name ];
              style = "Regular";
              size = config.stylix.fonts.sizes.desktop + 0.0;
            };
          }
        ];
      };
      extraConfig = ''
        #blur enable
      '';
    };

    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
