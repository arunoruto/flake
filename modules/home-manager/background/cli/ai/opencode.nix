{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./opencode-theme.nix
  ];

  config = lib.mkIf config.programs.opencode.enable {
    programs.opencode = {
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
  };
}
