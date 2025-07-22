{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hd-idle;

  # Function to generate the command-line arguments from the settings
  generateArgs =
    settings:
    let
      # Default idle time argument
      defaultIdleTimeArg = lib.optionalString (
        settings.defaultIdleTime != null
      ) "-i ${toString settings.defaultIdleTime}";

      # Per-disk idle time arguments
      diskIdleTimeArgs = lib.attrsets.mapAttrsToList (
        name: time: "-t ${name} -i ${toString time}"
      ) settings.diskIdleTimes;

      # Log file argument
      logFileArg = lib.optionalString (settings.logFile != null) "-l ${settings.logFile}";

    in
    lib.concatStringsSep " " (
      [
        defaultIdleTimeArg
        logFileArg
      ]
      ++ diskIdleTimeArgs
      ++ settings.extraArgs
    );

in
{
  # Define the options for the hd-idle service
  options.services.hd-idle = {
    enable = lib.mkEnableOption (lib.mdDoc "hd-idle, a utility to spin down idle hard disks");

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.hd-idle;
      defaultText = lib.literalExpression "pkgs.hd-idle";
      description = lib.mdDoc "The hd-idle package to use.";
    };

    settings = {
      defaultIdleTime = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = 600;
        example = 600;
        description = lib.mdDoc "Default idle time in seconds for all disks unless overridden. Required if service is enabled.";
      };

      diskIdleTimes = lib.mkOption {
        type = lib.types.attrsOf lib.types.int;
        default = { };
        example = lib.literalExpression ''
          {
            sda = 300; # 5 minutes
            sdb = 1200; # 20 minutes
          }
        '';
        description = lib.mdDoc "Per-disk idle time settings in seconds. Overrides the default idle time for specified disks.";
      };

      logFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/var/log/hd-idle.log";
        description = lib.mdDoc "Path to the log file for hd-idle.";
      };

      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "-d" ];
        description = lib.mdDoc "A list of extra command-line arguments to pass to hd-idle.";
      };
    };
  };

  # Configure the systemd service if it's enabled
  config = lib.mkIf cfg.enable {
    # Assertion to ensure that a default idle time is set if the service is enabled.
    assertions = [
      {
        assertion = cfg.settings.defaultIdleTime != null || cfg.settings.diskIdleTimes != { };
        message = "You must specify either `services.hd-idle.settings.defaultIdleTime` or at least one disk in `services.hd-idle.settings.diskIdleTimes`.";
      }
    ];

    systemd.services.hd-idle = {
      description = "hd-idle - spin down idle hard disks";
      documentation = [ "man:hd-idle(8)" ];
      after = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
        "suspend-then-hibernate.target"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} ${generateArgs cfg.settings}";
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
