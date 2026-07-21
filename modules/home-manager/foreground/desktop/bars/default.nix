{
  config,
  pkgs,
  lib,
  ...
  # }@args:
}:
let
  isLinux = pkgs.stdenv.isLinux;
in
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
        enable = lib.mkDefault isLinux; # Quickshell only works on Linux
        package = lib.mkDefault pkgs.unstable.quickshell;
        activeConfig = lib.mkDefault "caelestia";
        # config-name = lib.mkDefault "caelestia";
        systemd.target = lib.mkDefault "hyprland-session.target";

        # caelestia.enable = lib.mkDefault true;
      };
    };
  };
}
