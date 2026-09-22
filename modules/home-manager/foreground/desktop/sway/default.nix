{
  pkgs,
  lib,
  config,
  osConfig ? null,
  ...
}:
let
  # Same as hyprland and niri: the NixOS module owns the session, and the
  # home-manager side follows it instead of carrying its own default.
  hasSway =
    pkgs.stdenv.hostPlatform.isLinux && osConfig != null && (osConfig.programs.sway.enable or false);

  image = "~/Pictures/wallpapers/anime/cafe-at-night.png";
  lockscreen = "${lib.getExe config.programs.swaylock.package} --image ${image}";
in
{
  imports = [
    ./keybindings.nix
  ];

  config = lib.mkMerge [
    { wayland.windowManager.sway.enable = lib.mkDefault hasSway; }

    (lib.mkIf config.wayland.windowManager.sway.enable {
      # The launcher, locker and bar the config below calls.
      programs = {
        rofi.enable = lib.mkDefault true;
        swaylock.enable = lib.mkDefault true;
        waybar.enable = lib.mkDefault true;
      };

      wayland.windowManager.sway = {
        # With the NixOS module installing sway, a second copy here would only
        # shadow it (the cost: no config reload on activation).
        package = lib.mkIf hasSway null;

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
              command = lib.getExe config.programs.waybar.package;
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

      # Portals: the NixOS sway module writes sway's portal config and
      # modules/nixos/desktop/wayland.nix supplies the gtk + wlr backends.
    })
  ];
}
