{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.opencode;
  webCfg = cfg.web;
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.opencode = {
    skills = lib.mkOption {
      type = lib.types.either (lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path)) lib.types.path;
      default = { };
      description = ''
        Custom agent skills for opencode.

        This option can either be:
        - An attribute set defining skills
        - A path to a directory containing multiple skill folders

        If an attribute set is used, the attribute name becomes the skill directory name,
        and the value is either:
        - Inline content as a string (creates `opencode/skill/<name>/SKILL.md`)
        - A path to a file (creates `opencode/skill/<name>/SKILL.md`)
        - A path to a directory (creates `opencode/skill/<name>/` with all files)

        If a path is used, it is expected to contain one folder per skill name, each
        containing a {file}`SKILL.md`. The directory is symlinked to
        {file}`$XDG_CONFIG_HOME/opencode/skill/`.

        See <https://opencode.ai/docs/skills/> for the documentation.
      '';
      example = lib.literalExpression ''
        {
          git-release = '''
            ---
            name: git-release
            description: Create consistent releases and changelogs
            ---

            ## What I do

            - Draft release notes from merged PRs
            - Propose a version bump
            - Provide a copy-pasteable `gh release create` command
          ''';

          # A skill can also be a directory containing SKILL.md and other files.
          data-analysis = ./skills/data-analysis;
        }
      '';
    };

    web = {
      enable = lib.mkEnableOption "opencode web service";
      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "--hostname"
          "0.0.0.0"
          "--port"
          "4096"
          "--mdns"
          "--cors"
          "https://example.com"
          "--cors"
          "http://localhost:3000"
          "--print-logs"
          "--log-level"
          "DEBUG"
        ];
        description = ''
          Extra arguments to pass to the opencode web command.

          These arguments override the "server" options defined in the configuration file.
          See <https://opencode.ai/docs/web/#config-file> for available options.
        '';
      };
    };

    omo = {
      enable = lib.mkEnableOption "Oh My OpenAgent (OMO) configuration" // {
        default = builtins.elem "oh-my-openagent" cfg.settings.plugin;
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          # This allows ANY valid JSON structure to be passed, merging it with the explicit options below
          freeformType = jsonFormat.type;

          options = {
            agents = lib.mkOption {
              type = lib.types.attrsOf jsonFormat.type;
              default = { };
              description = "Specific model configurations for OMO agents.";
              example = lib.literalExpression ''
                {
                  sisyphus.model = "opencode-go/kimi-k2.5";
                }
              '';
            };

            categories = lib.mkOption {
              type = lib.types.attrsOf jsonFormat.type;
              default = { };
              description = "Category routing configurations for ultrawork delegation.";
              example = lib.literalExpression ''
                {
                  ultrabrain.model = "opencode-go/glm-5.1";
                }
              '';
            };

            fallback_models = lib.mkOption {
              type = lib.types.listOf jsonFormat.type;
              default = [ ];
              description = "Fallback models to use when API rate limits or errors occur.";
            };

            sisyphus_agent = lib.mkOption {
              type = jsonFormat.type;
              default = { };
              description = "Configuration for the Sisyphus orchestration system (planner, replace default plan).";
            };
          };
        };
        default = { };
        description = ''
          Configuration options for oh-my-openagent. 
          This is a freeform JSON attribute set. Any attributes defined here will be 
          serialized to oh-my-openagent.jsonc.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services = lib.mkIf (webCfg.enable && pkgs.stdenv.isLinux) {
      opencode-web = {
        Unit = {
          Description = "OpenCode Web Service";
          After = [ "network.target" ];
        };

        Service = {
          ExecStart = "${lib.getExe cfg.package} serve ${lib.escapeShellArgs webCfg.extraArgs}";
          Restart = "always";
          RestartSec = 5;
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };

    xdg.configFile = {
      "opencode/skill" = lib.mkIf (lib.isPath cfg.skills) {
        source = cfg.skills;
        recursive = true;
      };
    }
    // lib.optionalAttrs cfg.omo.enable {
      "opencode/oh-my-openagent.jsonc".source = jsonFormat.generate "oh-my-openagent.jsonc" (
        {
          "$schema" =
            "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";
        }
        // cfg.omo.settings
      );
    }
    // lib.mapAttrs' (
      name: content:
      if
        (lib.isPath content && lib.pathIsDirectory content)
        || (builtins.isString content && lib.hasPrefix builtins.storeDir content)
      then
        lib.nameValuePair "opencode/skill/${name}" {
          source = content;
          recursive = true;
        }
      else
        lib.nameValuePair "opencode/skill/${name}/SKILL.md" (
          if lib.isPath content then { source = content; } else { text = content; }
        )
    ) (if builtins.isAttrs cfg.skills then cfg.skills else { });
  };
}
