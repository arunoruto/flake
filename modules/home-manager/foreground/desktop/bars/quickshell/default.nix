{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./caelestia.nix ];

  options.programs.quickshell = {
    enable = lib.mkEnableOption "Quickshell";
    package = lib.mkPackageOption pkgs "quickshell" { };
    config-name = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Name of the configuration file for Quickshell.";
      example = "quickshell";
    };
    target = lib.mkOption {
      type = lib.types.enum [
        "graphical-session"
        "hyprland-session"
      ];
      default = "graphical-session";
      description = ''
        The target for the systemd service. This determines when Quickshell
        will start. Use "graphical-session" for a general graphical session or
        "hyprland-session" for Hyprland-specific sessions.
      '';
    };
  };

  config =
    let
      cfg = config.programs.quickshell;
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];

      systemd.user.services.quickshell = {
        Unit = {
          Description = "A very segsy desktop shell.";
          After = [ "${cfg.target}.target" ];
          Requires = [ "${cfg.target}.target" ];
        };
        Service = {
          Type = "exec";
          ExecStart = "${lib.getBin cfg.package}/bin/qs --config ${cfg.config-name}";
          Restart = "on-failure";
          Slice = "app-graphical.slice";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
      # [Unit]
      # Description=A very segsy desktop shell.
      # After=graphical-session.target

      # [Service]
      # Type=exec
      # ExecStart=$shell/run.fish
      # Restart=on-failure
      # Slice=app-graphical.slice

      # [Install]
      # WantedBy=graphical-session.target
    };
}
