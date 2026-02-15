{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.opencode;
  webCfg = cfg.web;
in
{
  imports = [
    # ./opencode-theme.nix
  ];

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
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      web = {
        # enable = lib.mkDefault (!(config.hosts.laptop.enable || config.hosts.headless.enable));
        enable = lib.mkDefault (!(config.hosts.headless.enable));
        extraArgs = [
          "--port"
          "4096"
        ];
      };
      package = pkgs.unstable.opencode;
      # package = pkgs.custom.opencode;
      settings = {
        theme = "stylix";
        # tools = {
        #   bash = true;
        #   edit = true;
        #   write = true;
        #   read = true;
        #   grep = true;
        #   glob = true;
        #   list = true;
        # };
        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          # options.baseURL = "http://madara.king-little.ts.net:11434/v1";
          options.baseURL = lib.mkDefault config.programs.ollama.defaultPath;
          models = {
            "ministral-3:3b" = {
              name = "Ministral - Mini";
              tool_call = true;
            };
            "ministral-3:8b" = {
              name = "Ministral - Midi";
              tool_call = true;
            };
            "ministral-3:14b" = {
              name = "Ministral - Maxi";
              tool_call = true;
            };
            "gemma3:4b" = {
              name = "Gemma3 Mini";
              tool_call = false;
            };
            "gemma3:12b" = {
              name = "Gemma3";
              tool_call = false;
            };
            "deepseek-r1:14b" = {
              name = "DeepSeek-R1";
              # tools = true;
              reasoning = true;
            };
            "qwen3:14b" = {
              name = "Qwen3";
              tools = true;
              reasoning = true;
            };
          };
        };
        permission = {
          edit = "ask";
          bash = {
            ls = "allow";
            pwd = "allow";
            "git status" = "allow";
            "git diff*" = "allow";
            "git log*" = "allow";
            # "git add*" = "allow";
          };
        };
        agent = {
          autoaccept = {
            mode = "primary";
            tools = {
              write = true;
              edit = true;
              bash = true;
            };
            permission = {
              edit = "allow";
              skill."*" = "allow";
            };
          };
        };
        plugin = [ "opencode-gemini-auth@latest" ];
      };
      agents = {
        commit = ./agents/COMMIT.md;
        summirizer = ./agents/ACADEMIC-SUMMARIZER.md;
        questioner = ./agents/ACADEMIC-QUESTIONER.md;
      };
      skills = {
        # beads = pkgs.unstable.beads.src + "/skills/beads";
        beads = pkgs.unstable.beads.src + "/claude-plugin/skills/beads";
        commit = ./skills/commit;
      };
      enableMcpIntegration = true;
    };

    systemd.user.services = lib.mkIf (webCfg.enable && pkgs.stdenv.isLinux) {
      opencode-web = {
        Unit = {
          Description = "OpenCode Web Service";
          After = [ "network.target" ];
        };

        Service = {
          ExecStart = "${lib.getExe cfg.package} web ${lib.escapeShellArgs webCfg.extraArgs}";
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
