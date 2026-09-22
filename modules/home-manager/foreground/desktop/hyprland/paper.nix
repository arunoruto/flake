# hyprpaper settings, applied whenever home-manager's `services.hyprpaper` is
# on (hyprland/default.nix and stylix's hyprpaper target both turn it on).
{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.hyprpaper.enable {
    services.hyprpaper.settings = {
      splash = lib.mkDefault true;
      ipc = false;
    };

    # The unit binds to graphical-session.target, which a GNOME session on
    # the same host activates too.
    systemd.user.services.hyprpaper = {
      Unit.ConditionEnvironment = lib.mkForce [
        "WAYLAND_DISPLAY"
        "XDG_CURRENT_DESKTOP=Hyprland"
      ];
    };
  };
}
