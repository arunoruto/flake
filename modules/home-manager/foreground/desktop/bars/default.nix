{
  config,
  pkgs,
  lib,
  ...
  # }@args:
}:
{
  imports = [
    ./eww
    ./waybar
  ];

  # config = lib.mkIf (args ? nixosConfig) {
  config = lib.mkIf config.foreground.enable {
    bars = {
      eww.enable = lib.mkDefault false;
      waybar.enable = lib.mkDefault false;
    };

    programs = {
      quickshell = {
        # Opt-in: it is a whole desktop shell, and with `configs` empty there
        # is nothing for it to load anyway.
        enable = lib.mkDefault false;
        package = lib.mkDefault pkgs.unstable.quickshell;
        activeConfig = lib.mkDefault "caelestia";
        # config-name = lib.mkDefault "caelestia";
        # graphical-session.target, not hyprland-session.target: under uwsm the
        # latter does not exist (see hyprland/default.nix).
        systemd.target = lib.mkDefault config.wayland.systemd.target;

        # caelestia.enable = lib.mkDefault true;
      };
    };
  };
}
