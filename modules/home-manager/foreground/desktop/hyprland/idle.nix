{
  lib,
  config,
  ...
}:
# hypridle settings, applied whenever home-manager's `services.hypridle` is on
# (hyprland/default.nix turns it on).
let
  # hypridle is its own project and still reads hyprlang -- only the
  # compositor moved to Lua. What did change is `hyprctl dispatch`, which now
  # takes a Lua expression instead of a dispatcher name.
  dpms = action: "hyprctl dispatch 'hl.dsp.dpms({ action = \"${action}\" })'";
in
{
  config = lib.mkIf config.services.hypridle.enable {
    services.hypridle = {
      settings = {
        general = {
          after_sleep_cmd = dpms "enable";
          ignore_dbus_inhibit = false;
          # pidof guard: without it a second lock instance stacks on the first.
          lock_cmd = "pidof hyprlock || hyprlock";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 1200;
            on-timeout = dpms "disable";
            on-resume = dpms "enable";
          }
        ];
      };
    };

    # The service binds to graphical-session.target, which a GNOME session on
    # the same host activates too -- and there is no hyprctl to talk to there.
    systemd.user.services.hypridle = {
      Unit.ConditionEnvironment = lib.mkForce [
        "WAYLAND_DISPLAY"
        "XDG_CURRENT_DESKTOP=Hyprland"
      ];
    };
  };
}
