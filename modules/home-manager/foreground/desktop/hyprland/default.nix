# Hyprland >= 0.55 is configured in Lua, not hyprlang: the config file is
# `hypr/hyprland.lua` and every setting is a call into the `hl` table.
# home-manager renders `settings.<name>` as `hl.<name>(<args>)`, so:
#
#   settings.config     = { ... }                 ->  hl.config({ ... })
#   settings.monitor    = [ { ... } ]             ->  hl.monitor({ ... }) per entry
#   settings.<n>._args  = [ a b ]                 ->  hl.<n>(a, b)
#   settings.<n>._var   = "x"                     ->  local <n> = "x"
#   mkLuaInline "expr"                            ->  raw Lua, unquoted
#
# https://wiki.hypr.land/Configuring/Core/
{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  cfg = config.wayland.windowManager.hyprland;

  # The NixOS module is what makes a *session* exist: the wayland session entry
  # for the display manager, the cap_sys_nice wrapper, the portal and (with
  # uwsm) the session units. Following it here means a host opts in exactly
  # once, with `programs.hyprland.enable`, the same way niri does.
  hasHyprland =
    pkgs.stdenv.hostPlatform.isLinux
    && osConfig != null
    && (osConfig.programs.hyprland.enable or false);

  uwsm = osConfig != null && (osConfig.programs.hyprland.withUWSM or false);
in
{
  imports = [
    ./binds.nix
    ./idle.nix
    ./lock.nix
    ./paper.nix
  ];

  config = lib.mkMerge [
    { wayland.windowManager.hyprland.enable = lib.mkDefault hasHyprland; }

    (lib.mkIf cfg.enable {
      hypr = {
        binds.enable = lib.mkDefault true;
        idle.enable = lib.mkDefault true;
        lock.enable = lib.mkDefault true;
        paper.enable = lib.mkDefault true;
      };

      wayland.windowManager.hyprland = {
        # Hyprland and xdph come from the NixOS module. Installing a second
        # copy here is how you end up running two builds against one portal.
        package = null;
        portalPackage = null;

        # home-manager only defaults to Lua from home.stateVersion 26.05 on,
        # and ours is pinned at 23.05 (an install-time fact, never bumped), so
        # the modern renderer has to be asked for by name.
        configType = "lua";

        # uwsm owns graphical-session.target; hyprland-session.target would
        # race it. Without uwsm, flip this back on.
        systemd.enable = !uwsm;

        settings = {
          # Fallback rule for any monitor without one of its own. Hosts
          # override it with explicit rules -- see docs/hyprland.md.
          monitor = lib.mkDefault [
            {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = "auto";
            }
          ];

          config = {
            general = {
              gaps_in = 3;
              gaps_out = 5;
              border_size = 2;
              layout = "dwindle";
              # https://wiki.hypr.land/Configuring/Extra/Tearing/
              allow_tearing = false;
            };

            decoration = {
              rounding = 10;

              blur = {
                enabled = true;
                size = 3;
                passes = 1;
                vibrancy = 0.1696;
              };

              shadow = {
                enabled = true;
                range = 4;
                render_power = 3;
              };
            };

            animations.enabled = true;

            dwindle = {
              preserve_split = true;
            };

            input = {
              kb_layout = config.keyboard.layout;
              kb_variant = config.keyboard.variant;

              follow_mouse = 1;
              sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

              touchpad.natural_scroll = true;
            };

            # XWayland clients render blurry on fractional scales otherwise.
            xwayland.force_zero_scaling = true;

            ecosystem = {
              no_update_news = true;
              no_donation_nag = true;
            };
          };

          # `curve` is one of home-manager's importantPrefixes, so these are
          # emitted before the animations that name them.
          curve = [
            {
              _args = [
                "myBezier"
                {
                  type = "bezier";
                  points = [
                    [
                      0.05
                      0.9
                    ]
                    [
                      0.1
                      1.05
                    ]
                  ];
                }
              ];
            }
          ];

          animation = [
            {
              leaf = "windows";
              enabled = true;
              speed = 7;
              bezier = "myBezier";
            }
            {
              leaf = "windowsOut";
              enabled = true;
              speed = 7;
              bezier = "default";
              style = "popin 80%";
            }
            {
              leaf = "border";
              enabled = true;
              speed = 10;
              bezier = "default";
            }
            {
              leaf = "fade";
              enabled = true;
              speed = 7;
              bezier = "default";
            }
            {
              leaf = "workspaces";
              enabled = true;
              speed = 6;
              bezier = "default";
            }
          ];
        };
      };

      # uwsm starts the compositor from a systemd unit rather than a login
      # shell, so home-manager's session variables have to be handed over.
      # https://wiki.hypr.land/Useful-Utilities/uwsm/
      xdg.configFile = lib.mkMerge [
        (lib.mkIf uwsm {
          "uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
        })
        # home-manager only writes this when it owns the Hyprland package; with
        # the NixOS module the Lua stubs live in the system profile instead.
        {
          "hypr/.luarc.json".text = builtins.toJSON {
            workspace.library = [ "/run/current-system/sw/share/hypr/stubs" ];
            diagnostics.globals = [ "hl" ];
          };
        }
      ];

      programs.wofi.enable = true;

      # Upstream's "must-have" list: an authentication agent and a notification
      # daemon. Without the latter, apps that wait on org.freedesktop.
      # Notifications (Discord is the classic) just hang. mako is D-Bus
      # activated rather than a unit, so a GNOME session on the same host
      # simply keeps owning the bus name and mako never starts there.
      # https://wiki.hypr.land/Useful-Utilities/Must-have/
      services = {
        hyprpolkitagent.enable = lib.mkDefault true;
        mako.enable = lib.mkDefault true;
      };

      home.packages = with pkgs; [
        brightnessctl # the function-key binds use it
        hyprpicker
        hyprshot
      ];
    })
  ];
}
