{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./module.nix
    ./omo.nix
  ];

  programs.opencode = {
    enableMcpIntegration = true;
    web = {
      # Disable on laptops, enable on desktop workstations
      enable = lib.mkDefault (config.hosts.desktop.enable && !config.hosts.laptop.enable);
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
          # "gemma3:4b" = {
          #   name = "Gemma3 Mini";
          #   tool_call = false;
          # };
          # "gemma3:12b" = {
          #   name = "Gemma3";
          #   tool_call = false;
          # };
          "gemma4:e4b-16k" = {
            name = "Gemma 4 E4B (16k)";
            id = "gemma4:e4b-16k";
            tool_call = true;
            maxTokens = 16384;
            options = {
              temperature = 0.1;
            };
          };

          "gemma4:e2b-32k" = {
            name = "Gemma 4 E2B (32k)";
            id = "gemma4:e2b-32k";
            tool_call = true;
            maxTokens = 32768;
            options = {
              temperature = 0.1;
            };
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
        todowrite = "allow";
        todoread = "allow";
        edit = "ask";
        write = {
          ".opencode/plans/**" = "allow";
        };
        bash = {
          ls = "allow";
          pwd = "allow";
          "git status" = "allow";
          "git diff*" = "allow";
          "git log*" = "allow";
          # "git add*" = "allow";
          "mkdir -p .opencode/plans" = "allow";
          ssh = "deny";
        };
      };
      agent = {
        compact.model = "github-copilot/gpt-5.3-codex";
        autoaccept = {
          mode = "primary";
          tools = {
            todowrite = true;
            todoread = true;
            write = true;
            edit = true;
            bash = true;
          };
          permission = {
            edit = "deny";
            skill."*" = "allow";
          };
        };
      };
      plugin = [
        "opencode-gemini-auth@latest"
        "oh-my-openagent"
      ];
    };
    agents = {
      commit = ../agents/COMMIT.md;
      summirizer = ../agents/ACADEMIC-SUMMARIZER.md;
      questioner = ../agents/ACADEMIC-QUESTIONER.md;
      caveman = ../agents/CAVEMAN.md;
    };
    skills = {
      # beads = pkgs.unstable.beads.src + "/skills/beads";
      beads = pkgs.unstable.beads.src + "/claude-plugin/skills/beads";
      commit = ../skills/commit;
      devenv = ../skills/devenv;
    };
    rules = ../AGENTS.md;
  };
}
