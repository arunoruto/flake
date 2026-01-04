{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.opencode;
in
{
  imports = [
    # ./opencode-theme.nix
  ];

  options.programs.opencode.web = {
    enable = lib.mkEnableOption "OpenCode Web Service";

    host = lib.mkOption {
      type = lib.types.str;
      # default = "127.0.0.1";
      # example = "0.0.0.0";
      default = "0.0.0.0";
      example = "127.0.0.1";
      description = "The hostname or IP address to bind the web server to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4096;
      description = "The port to run the web server on.";
    };

    mdns = lib.mkEnableOption "mDNS service discovery (defaults hostname to 0.0.0.0)";

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

    cors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "https://mydashboard.local"
        "http://localhost:3000"
      ];
      description = "Additional domains to allow for CORS.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
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
          commit = ./commit.md;
        };
        enableMcpIntegration = true;
      };
    })
    (lib.mkIf cfg.web.enable {
      systemd.user.services.opencode-web = {
        Unit = {
          Description = "OpenCode Web Service";
          After = [ "network.target" ];
        };

        Service = {
          ExecStart =
            let
              webCfg = cfg.web;
              args = [
                "web"
                "--hostname ${webCfg.host}"
                "--port ${toString webCfg.port}"
                "--log-level ${webCfg.logLevel}"
              ]
              ++ lib.optional webCfg.mdns "--mdns"
              ++ lib.optional webCfg.printLogs "--print-logs"
              ++ map (domain: "--cors ${domain}") webCfg.cors;
            in
            "${cfg.package}/bin/opencode ${lib.concatStringsSep " " args}";
          Restart = "always";
          RestartSec = 5;
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    })
  ];
}
