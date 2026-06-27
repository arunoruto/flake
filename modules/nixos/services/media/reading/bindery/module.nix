{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.bindery;
in
{
  options = {
    services.bindery = {
      enable = lib.mkEnableOption "Bindery, an automated book download manager";

      package = lib.mkPackageOption pkgs "bindery" { };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/bindery";
        description = ''
          The directory where Bindery stores its SQLite database, image cache, and configuration.
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8787;
        description = "The port on which Bindery listens for incoming HTTP requests.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open ports in the firewall for Bindery.";
      };

      telemetry = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Whether to send anonymous crash and usage statistics to the developer.
            Defaults to false for maximum privacy.
          '';
        };
      };

      environmentFiles = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        example = [ "/run/secrets/bindery.env" ];
        description = ''
          Files containing environment variables to pass to Bindery.
          Useful for securely setting secrets like OIDC credentials or BINDERY_OUTBOUND_PROXY.
        '';
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "bindery";
        description = "User account under which Bindery runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "bindery";
        description = "Group under which Bindery runs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.settings."10-bindery".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    systemd.services.bindery = {
      description = "Bindery Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        BINDERY_PORT = toString cfg.port;
        BINDERY_DATA_DIR = cfg.dataDir;
        BINDERY_TELEMETRY_DISABLED = if cfg.telemetry.enable then "false" else "true";
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = cfg.environmentFiles;
        # Uses lib.getExe to automatically point to result/bin/bindery
        # (relies on mainProgram = "bindery" being set in the package meta)
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "on-failure";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    users.users = lib.mkIf (cfg.user == "bindery") {
      bindery = {
        description = "Bindery service user";
        home = cfg.dataDir;
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "bindery") {
      bindery = { };
    };
  };
}
