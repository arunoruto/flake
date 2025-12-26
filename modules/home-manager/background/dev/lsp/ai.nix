{ pkgs, lib, config, ... }:
let
  cfg = config.programs.dev;

  copilotSecretPath = lib.attrByPath [ "sops" "secrets" "tokens/copilot" "path" ] null config;
  copilotApiKeyScript = lib.optionalString (copilotSecretPath != null) ''
    COPILOT_API_KEY="$(cat ${copilotSecretPath})"
    export COPILOT_API_KEY
    export HANDLER=copilot
  '';
in
{
  programs.dev.lsp.servers = {
      copilot = {
        enable = lib.mkOptionDefault false;
        kind = "ai";
        package = pkgs.unstable.copilot-language-server;
        command = lib.getExe pkgs.unstable.copilot-language-server;
        args = [ "--stdio" ];
      };

      gpt = {
        enable = lib.mkDefault (cfg.languages.python.enable or false);
        kind = "ai";
        exposeToOpencode = false;
        tags = [ "python" ];
        package = pkgs.helix-gpt;
        command = lib.getExe pkgs.helix-gpt;
        args = [ "--handler" "copilot" ];
        environmentScript = copilotApiKeyScript;
      };

      lsp-ai = {
        enable = lib.mkOptionDefault false;
        kind = "ai";
        package = pkgs.lsp-ai;
        command = lib.getExe pkgs.lsp-ai;
        args = [ "--use-seperate-log-file" ];
        settings = {
          memory.file_store = { };
          models = {
            copilot = {
              type = "open_ai";
              chat_endpoint = "https://api.githubcopilot.com/chat/completions";
              model = "";
              auth_token_env_var_name = "GITHUB_TOKEN";
            };
            deepseek-ollama =
              let
                url = "madara.king-little.ts.net";
              in
              {
                type = "ollama";
                model = "deepseek-coder-v2:16b";
                chat_endpoint = "http://${url}:11434/api/chat";
                generate_endpoint = "http://${url}:11434/api/generate";
              };
          };

          completion = {
            model = "copilot";
            parameters = {
              max_token = 500;
              max_context = 2048;
            };
            messages = [
              {
                role = "system";
                content = ''
                  Instructions:
                  - You are an AI programming assistant.
                  - Given a piece of code with the cursor location marked by "<CURSOR>", replace "<CURSOR>" with the correct code or comment.
                  - First, think step-by-step.
                  - Describe your plan for what to build in pseudocode, written out in great detail.
                  - Then output the code replacing the "<CURSOR>"
                  - Ensure that your completion fits within the language context of the provided code snippet (e.g., Python, JavaScript, Rust).
                  Rules:
                  - Only respond with code or comments.
                  - Only replace "<CURSOR>"; do not include any previously written code.
                  - Never include "<CURSOR>" in your response
                  - If the cursor is within a comment, complete the comment meaningfully.
                  - Handle ambiguous cases by providing the most contextually appropriate completion.
                  - Be consistent with your responses.
                '';
              }
              {
                role = "user";
                content = ''
                  def greet(name):
                      print(f"Hello, {<CURSOR>}")
                '';
              }
              {
                role = "assistant";
                content = "name";
              }
              {
                role = "user";
                content = ''
                  function sum(a, b) {
                      return a + <CURSOR>;
                  }
                '';
              }
              {
                role = "assistant";
                content = "b";
              }
              {
                role = "user";
                content = ''
                  fn multiply(a: i32, b: i32) -> i32 {
                      a * <CURSOR>
                  }
                '';
              }
              {
                role = "assistant";
                content = "b";
              }
              {
                role = "user";
                content = ''
                  # <CURSOR>
                  def add(a, b):
                      return a + b
                '';
              }
              {
                role = "assistant";
                content = "Adds two numbers";
              }
              {
                role = "user";
                content = ''
                  # This function checks if a number is even
                  <CURSOR>
                '';
              }
              {
                role = "assistant";
                content = ''
                  def is_even(n):
                      return n % 2 == 0
                '';
              }
              {
                role = "user";
                content = "{CODE}";
              }
            ];
          };
        };
      };
  };
}
