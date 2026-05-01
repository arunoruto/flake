{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pi;
  tauCfg = cfg.tau;
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.pi = {
    enable = lib.mkEnableOption "pi-coding-agent";

    package = lib.mkPackageOption pkgs "pi-coding-agent" { };

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = "JSON settings written to ~/.pi/agent/settings.json";
    };

    rules = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.lines lib.types.path);
      default = null;
      description = ''
        Global pi AGENTS instructions.

        - If a path is provided, it is symlinked to ~/.pi/agent/AGENTS.md
        - If a string is provided, it is written as ~/.pi/agent/AGENTS.md
      '';
    };

    extensions = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = ''
        Pi extensions to install into ~/.pi/agent/extensions.

        Attribute key = extension name.
        Attribute value = path to either:
        - a .ts file (linked as ~/.pi/agent/extensions/<name>.ts)
        - a directory (linked as ~/.pi/agent/extensions/<name>/)

        Note: this intentionally avoids recursive copies to keep activation/runtime snappy.
      '';
      example = lib.literalExpression ''
        {
          guard = ./extensions/guard.ts;
          planner = ./extensions/planner;
        }
      '';
    };

    tau = {
      enable = lib.mkEnableOption "Tau mirror backend service for pi";

      port = lib.mkOption {
        type = lib.types.port;
        default = 3939;
        description = "Tau mirror HTTP/WebSocket port.";
      };

      user = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional Tau basic-auth username.";
      };

      pass = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional Tau basic-auth password.";
      };

      authEnabled = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Whether Tau auth should be enabled by default.";
      };

      disabled = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Disable Tau auto-start behavior in the extension settings.";
      };

      projectsDir = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional Tau projects directory override.";
      };

      extension = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "npm:tau-mirror";
        description = "Tau extension source passed via `-e` when starting the service.";
      };

      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "--mode"
          "rpc"
        ];
        description = "Extra CLI args for the background pi process.";
      };

      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Extra environment variables for the Tau service.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [ cfg.package ];

    systemd.user.services = lib.mkIf (tauCfg.enable && pkgs.stdenv.isLinux) {
      pi-tau = {
        Unit = {
          Description = "Pi Tau backend (RPC)";
          After = [ "network.target" ];
        };

        Service = {
          ExecStart = "${lib.getExe pkgs.bash} -lc ${lib.escapeShellArg (
            "exec ${lib.getExe cfg.package} ${
              lib.escapeShellArgs (
                (lib.optionals (tauCfg.extension != null) [
                  "-e"
                  tauCfg.extension
                ])
                ++ tauCfg.extraArgs
              )
            } < <(${lib.getExe' pkgs.coreutils "tail"} -f /dev/null)"
          )}";
          Restart = "always";
          RestartSec = 5;

          Environment = lib.mapAttrsToList (name: value: "${name}=${value}") (
            lib.filterAttrs (_: v: v != null) (
              tauCfg.environment
              // {
                TAU_MIRROR_PORT = toString tauCfg.port;
                PI_CODING_AGENT_DIR = "%h/.pi/agent";
                TAU_DISABLED = if tauCfg.disabled then "1" else "0";

                TAU_USER = tauCfg.user;
                TAU_PASS = tauCfg.pass;
                TAU_PROJECTS_DIR = tauCfg.projectsDir;
              }
            )
          );
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };

    home.file = {
      ".pi/agent/settings.json".source = jsonFormat.generate "pi-settings.json" (
        lib.recursiveUpdate cfg.settings (
          lib.optionalAttrs tauCfg.enable (
            {
              tau = lib.filterAttrs (_: v: v != null) {
                inherit (tauCfg)
                  user
                  pass
                  authEnabled
                  projectsDir
                  port
                  disabled
                  ;
              };
            }
            // lib.optionalAttrs (!cfg.settings ? npmCommand) {
              npmCommand = [
                # "${pkgs.nodejs}/bin/npm"
                (lib.getExe (builtins.elemAt cfg.package.buildInputs 0))
                "--prefix"
                "${config.home.homeDirectory}/.pi/agent/npm"
              ];
            }
          )
        )
      );

      ".pi/agent/AGENTS.md" = lib.mkIf (cfg.rules != null) (
        if lib.isPath cfg.rules then { source = cfg.rules; } else { text = cfg.rules; }
      );
    }
    // lib.mapAttrs' (
      name: path:
      let
        isDir = lib.pathIsDirectory path;
        target = if isDir then ".pi/agent/extensions/${name}" else ".pi/agent/extensions/${name}.ts";
      in
      lib.nameValuePair target { source = path; }
    ) cfg.extensions;
  };
}
