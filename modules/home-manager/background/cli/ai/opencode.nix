{
  config,
  lib,
  pkgs,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  cfg = config.programs.opencode;
  webCfg = cfg.web;
  webArgs = [
    "web"
    "--log-level"
    webCfg.logLevel
  ]
  ++ lib.optional webCfg.printLogs "--print-logs"
  ++ lib.optionals (webCfg.settings.hostname != null) [
    "--hostname"
    webCfg.hostname
  ]
  ++ lib.optionals (webCfg.settings.port != null) [
    "--port"
    (toString webCfg.port)
  ]
  ++ lib.optional webCfg.settings.mdns "--mdns"
  ++ lib.concatMap (domain: [
    "--cors"
    domain
  ]) webCfg.settings.cors;

in
{
  imports = [
    # ./opencode-theme.nix
  ];

  options.programs.opencode.web = {
    enable = lib.mkEnableOption "opencode web service";

    settings = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        freeformType = jsonFormat.type;
        options = {
          hostname = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            example = "0.0.0.0";
            description = "The hostname or IP address to bind the web server to. Defaults to `127.0.0.1`.";
          };

          port = lib.mkOption {
            type = with lib.types; nullOr port;
            default = null;
            description = "The port to run the web server on. If not set, a dynamic port will be chosen. It is recommended to set this option for a static port, for example 4096.";
          };

          mdns = lib.mkEnableOption "mDNS service discovery (defaults hostname to 0.0.0.0)";

          cors = lib.mkOption {
            type = with lib.types; (listOf str);
            default = [ ];
            example = [
              "https://mydashboard.local"
              "http://localhost:3000"
            ];
            description = "Additional domains to allow for CORS.";
          };
        };
      };
      description = "Web server settings. These map to the 'server' block in the config file.";
    };

    printLogs = lib.mkEnableOption "printing logs to stderr (useful for journalctl)";

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "DEBUG"
        "INFO"
        "WARN"
        "ERROR"
      ];
      default = "INFO";
      description = "Log verbosity level.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      web.enable = lib.mkDefault (!config.hosts.laptop.enable);
      package = pkgs.unstable.opencode;
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
      enableMcpIntegration = true;
    };

    systemd.user.services = lib.mkIf (webCfg.enable && pkgs.stdenv.isLinux) {
      opencode-web = {
        Unit = {
          Description = "OpenCode Web Service";
          After = [ "network.target" ];
        };

        Service = {
          ExecStart = "${lib.getExe cfg.package} ${lib.escapeShellArgs webArgs}";
          Restart = "always";
          RestartSec = 5;
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };

  };
}
