# Bars and shells. Each directory attaches this flake's layout to
# home-manager's own `programs.<name>.enable`; none of them is on by default
# (GNOME draws its own panel), so a compositor module or host turns on the
# one it uses.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./eww
    ./waybar
  ];

  config = lib.mkIf config.programs.quickshell.enable {
    programs.quickshell = {
      package = lib.mkDefault pkgs.unstable.quickshell;
      activeConfig = lib.mkDefault "caelestia";
      # graphical-session.target, not hyprland-session.target: under uwsm the
      # latter does not exist (see hyprland/default.nix).
      systemd.target = lib.mkDefault config.wayland.systemd.target;
    };
  };
}
