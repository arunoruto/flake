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
        provider.llama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options.baseURL = "http://madara.king-little.ts.net:11434/v1";
          models = {
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
      };
      enableMcpIntegration = true;
    };
  };
}
