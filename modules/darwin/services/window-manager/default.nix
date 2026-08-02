# Tiling window managers for darwin, and the parts they share.
#
# Pick one with the upstream flag — `services.yabai.enable` or
# `services.aerospace.enable`. yabai defaults on for `desktop`-tagged hosts
# (see ./yabai.nix); AeroSpace is off unless you ask for it.
#
# They cannot coexist: AeroSpace reimplements workspaces and hides windows by
# parking them off the side of the screen, while yabai tiles inside native macOS
# Spaces. Enable both and two daemons write conflicting frames to the same
# windows — hence the assertion.
{
  config,
  lib,
  ...
}:
let
  anyEnabled = with config.services; yabai.enable || aerospace.enable;
in
{
  imports = [
    ./aerospace.nix
    ./yabai.nix
  ];

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(config.services.yabai.enable && config.services.aerospace.enable);
          message = ''
            services.yabai and services.aerospace are both enabled, but they cannot
            share a machine: AeroSpace hides windows by moving them off-screen and
            expects to own workspace switching, while yabai tiles inside native
            macOS Spaces. Both would fight over the same window frames.

            Enable exactly one of them.
          '';
        }
      ];
    }

    (lib.mkIf anyEnabled {
      # A tiled window has no drop shadow separating it from its neighbour, and
      # macOS's own focus cue is just the title bar. JankyBorders draws a ring
      # instead; it is a plain CGS client, so it needs no scripting addition.
      #
      # No colours here on purpose: Stylix ships its own jankyborders target
      # (modules/jankyborders/darwin.nix upstream) and themes it from the active
      # scheme as soon as this service is enabled.
      services.jankyborders = {
        enable = lib.mkDefault true;
        style = lib.mkDefault "round";
        width = lib.mkDefault 4.0;
        hidpi = lib.mkDefault true;
      };

      system.defaults = {
        # Stop macOS reordering Spaces underneath the window manager. Matters
        # most for yabai, where `space --focus 3` addresses a Space by index.
        dock.mru-spaces = lib.mkDefault false;

        # Tiling retiles constantly; the open/close animation is pure latency.
        NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = lib.mkDefault false;
      };
    })
  ];
}
