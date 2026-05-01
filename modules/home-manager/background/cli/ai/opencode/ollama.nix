{
  config,
  lib,
  ...
}:
{

  programs.opencode.settings.provider.ollama = {
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
}
