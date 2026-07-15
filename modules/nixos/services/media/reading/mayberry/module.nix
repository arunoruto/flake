{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mayberry;
in
{
  options.services.mayberry = {
    enable = lib.mkEnableOption "Mayberry federated EPUB library daemon";

    package = lib.mkPackageOption pkgs "mayberry" { };

    libraryPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/srv/books/epub";
      description = "Path to the EPUB library folder. If left empty, Mayberry will start in setup wizard mode.";
    };

    branchName = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "my-awesome-library";
      description = "Branch display name. Auto-generates a friendly-id if left empty.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1950;
      description = "Local dashboard HTTP port.";
    };

    serverUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://mayberry.pub";
      description = "Town Square catalog server URL.";
    };

    hubUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://branch.pub";
      description = "Tunnel hub URL.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "mayberry";
      description = "User account under which the Mayberry daemon runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "mayberry";
      description = "Group under which the Mayberry daemon runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.mayberry = {
      description = "Mayberry Branch Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = lib.escapeShellArgs (
          [
            "${cfg.package}/bin/mayberry"
            "--daemon"
            "-port"
            (toString cfg.port)
            "-server"
            cfg.serverUrl
            "-hub"
            cfg.hubUrl
          ]
          ++ lib.optionals (cfg.libraryPath != "") [
            "-library"
            cfg.libraryPath
          ]
          ++ lib.optionals (cfg.branchName != "") [
            "-name"
            cfg.branchName
          ]
        );
        Restart = "on-failure";
        RestartSec = "5s";
        User = cfg.user;
        Group = cfg.group;

        # This tells systemd to automatically create /var/lib/mayberry with correct permissions
        StateDirectory = "mayberry";
        WorkingDirectory = "%S/mayberry";

        # Mayberry writes branch.json to ~/.mayberry/. By setting HOME to the StateDirectory,
        # it neatly contains the config inside /var/lib/mayberry/.mayberry/ without touching real user homes.
        Environment = "HOME=%S/mayberry";

        # Security hardening
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    # Create the system user and group automatically
    users.users = lib.mkIf (cfg.user == "mayberry") {
      mayberry = {
        isSystemUser = true;
        group = cfg.group;
        description = "Mayberry daemon user";
        home = "/var/lib/mayberry";
      };
    };

    users.groups = lib.mkIf (cfg.group == "mayberry") {
      mayberry = { };
    };
  };
}
