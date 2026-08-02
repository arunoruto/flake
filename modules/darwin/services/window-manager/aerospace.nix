# AeroSpace — i3-style tiling window manager for macOS.
#
# Off by default on this host; see ./yabai.nix for what runs instead. Kept as
# the alternative — turn it on with `services.aerospace.enable = true` (and turn
# yabai off, or the assertion in ./default.nix will stop you).
#
# AeroSpace reimplements workspaces rather than driving the private WindowServer
# API, so it needs no scripting addition and no weakened SIP. The catch is *how*
# it hides a window: it moves it off the side of the screen. That is fine if
# AeroSpace owns workspace switching outright, and actively wrong if you also
# use native macOS Spaces — its guide says to pick one:
#
#   "The intended workflow of using AeroSpace workspaces is to only have one
#    macOS Space [...] and don't interact with macOS Spaces anymore."
#
# Note this is not the SIP trade-off it first looks like. yabai only needs a
# partially disabled SIP for space create/destroy/move/swap, sticky/pip/shadow
# and opacity; `space --focus` and `window --space` are not SIP-gated, so a
# native-Spaces workflow works fine on yabai with SIP fully enabled.
#
# AeroSpace has its own hotkey daemon, so there is no skhd here.
# Everything is mkDefault so a host can override.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # AeroSpace spells a chord "ctrl-alt-h". Deliberately not plain `alt` — see
  # the rationale in ./yabai.nix, which applies here too. Note AeroSpace only
  # understands cmd/alt/ctrl/shift, so the `lalt` trick mentioned there is not
  # available on this backend.
  mod = "ctrl-alt";

  workspaces = map toString (lib.range 1 9);

  # `mod-<n>` focuses a workspace, `mod-shift-<n>` throws the focused window
  # there and follows it.
  workspaceBindings = lib.listToAttrs (
    lib.concatMap (ws: [
      (lib.nameValuePair "${mod}-${ws}" "workspace ${ws}")
      (lib.nameValuePair "${mod}-shift-${ws}" "move-node-to-workspace ${ws} --focus-follows-window")
    ]) workspaces
  );

  directions = {
    h = "left";
    j = "down";
    k = "up";
    l = "right";
  };

  # hjkl to focus, shift+hjkl to move the window in the tree.
  motionBindings = lib.concatMapAttrs (key: dir: {
    "${mod}-${key}" = "focus ${dir}";
    "${mod}-shift-${key}" = "move ${dir}";
  }) directions;
in
{
  config = lib.mkIf config.services.aerospace.enable {
    services.aerospace = {
      package = lib.mkDefault pkgs.unstable.aerospace;

      settings = {
        # Opt in to the current config schema. Omitting this key silently pins
        # the file to `config-version = 1` semantics, and `persistent-workspaces`
        # below only exists from version 2 on.
        config-version = lib.mkDefault 2;

        # The config lives in the Nix store, so its path changes on every switch
        # and there is nothing to watch — reloads come from `just switch` (or
        # `mod-shift-semicolon` then `esc`).
        auto-reload-config = lib.mkDefault false;

        # Keep 1-9 around even while empty, so workspace numbers stay stable
        # instead of renumbering as windows come and go.
        persistent-workspaces = lib.mkDefault workspaces;

        # cmd-h hides an app out from under the tiler, and with a tiling layout
        # there is no Dock click to get it back. Undo it automatically.
        automatically-unhide-macos-hidden-apps = lib.mkDefault true;

        # Focus follows the keyboard only; the pointer sitting over a window
        # should not steal focus mid-tile.
        focus-follows-mouse.enabled = lib.mkDefault false;

        # Match i3: a new window splits the focused one, rather than being
        # appended after the whole container.
        enable-normalization-flatten-containers = lib.mkDefault true;
        enable-normalization-opposite-orientation-for-nested-containers = lib.mkDefault true;

        default-root-container-layout = lib.mkDefault "tiles";
        # Split along whichever axis the display is longer on, so the laptop
        # panel tiles vertically and a wide external monitor horizontally.
        default-root-container-orientation = lib.mkDefault "auto";

        accordion-padding = lib.mkDefault 24;

        # Keep the pointer with the focus, otherwise hover-sensitive apps on the
        # other monitor keep stealing scroll events.
        on-focused-monitor-changed = lib.mkDefault [ "move-mouse monitor-lazy-center" ];

        gaps = {
          inner = {
            horizontal = lib.mkDefault 8;
            vertical = lib.mkDefault 8;
          };
          outer = {
            top = lib.mkDefault 8;
            bottom = lib.mkDefault 8;
            left = lib.mkDefault 8;
            right = lib.mkDefault 8;
          };
        };

        # Apps that are actively bad at being tiled: transient utility panels
        # and anything whose window is really a dialog.
        on-window-detected = lib.mkDefault [
          {
            "if".app-id = "com.apple.systempreferences";
            run = [ "layout floating" ];
          }
          {
            "if".app-id = "com.apple.finder";
            "if".window-title-regex-substring = "Info";
            run = [ "layout floating" ];
          }
          {
            "if".app-id = "com.apple.ActivityMonitor";
            run = [ "layout floating" ];
          }
          {
            "if".app-id = "com.apple.calculator";
            run = [ "layout floating" ];
          }
          {
            "if".app-id = "com.apple.PhotoBooth";
            run = [ "layout floating" ];
          }
          {
            "if".app-id = "us.zoom.xos";
            run = [ "layout floating" ];
          }
        ];

        mode = {
          main.binding =
            motionBindings
            // workspaceBindings
            // {
              # i3's mod-enter. Ghostty on darwin is the real .app (nixpkgs' build
              # is a placeholder here), so go through `open` rather than a binary.
              "${mod}-enter" = "exec-and-forget open -na Ghostty";

              # Layout.
              "${mod}-slash" = "layout tiles horizontal vertical";
              "${mod}-comma" = "layout accordion horizontal vertical";
              "${mod}-f" = "fullscreen";
              "${mod}-space" = "layout floating tiling";

              # Resize the focused node without leaving the keyboard row.
              "${mod}-minus" = "resize smart -50";
              "${mod}-equal" = "resize smart +50";

              # Workspaces / monitors.
              "${mod}-tab" = "workspace-back-and-forth";
              "${mod}-shift-tab" = "move-workspace-to-monitor --wrap-around next";

              # Sub-modes. `esc` in either one reloads the config and returns.
              "${mod}-shift-semicolon" = "mode service";
              "${mod}-r" = "mode resize";
            };

          # Rarely-used surgery: joining containers, flattening the tree, and
          # closing everything but the focused window.
          service.binding = {
            esc = [
              "reload-config"
              "mode main"
            ];
            r = [
              "flatten-workspace-tree"
              "mode main"
            ];
            f = [
              "layout floating tiling"
              "mode main"
            ];
            backspace = [
              "close-all-windows-but-current"
              "mode main"
            ];

            h = [
              "join-with left"
              "mode main"
            ];
            j = [
              "join-with down"
              "mode main"
            ];
            k = [
              "join-with up"
              "mode main"
            ];
            l = [
              "join-with right"
              "mode main"
            ];
          };

          # Sticky resize: enter with `mod-r`, then hjkl repeatedly, `esc` to exit.
          resize.binding = {
            h = "resize width -50";
            j = "resize height +50";
            k = "resize height -50";
            l = "resize width +50";
            equal = "balance-sizes";
            esc = "mode main";
            enter = "mode main";
          };
        };
      };
    };

    # JankyBorders and the settings both backends want live in ./default.nix.
    # What stays here is AeroSpace-specific.
    system.defaults = {
      # "Displays have separate Spaces" off. Leaving it on gives AeroSpace focus
      # and performance problems, because each display gets its own Space and the
      # public API it drives goes unstable. Needs a logout to take effect.
      #
      # ./yabai.nix sets this back to the macOS default, since that backend has
      # no quarrel with per-display Spaces.
      spaces.spans-displays = lib.mkDefault true;

      # Mission Control groups by app, which is what you want once AeroSpace is
      # parking hidden windows in the screen corners.
      dock.expose-group-apps = lib.mkDefault true;
    };
  };
}
