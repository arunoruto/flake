{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pi;
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
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [ cfg.package ];

    home.file = {
      ".pi/agent/settings.json" = lib.mkIf (cfg.settings != { }) {
        source = jsonFormat.generate "pi-settings.json" cfg.settings;
      };

      ".pi/agent/AGENTS.md" = lib.mkIf (cfg.rules != null) (
        if lib.isPath cfg.rules then { source = cfg.rules; } else { text = cfg.rules; }
      );
    };
  };
}
