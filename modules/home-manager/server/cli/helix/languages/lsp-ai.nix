{ pkgs, lib, ... }:
{
  programs.helix = {
    languages = {
      language-server = {
        lsp-ai = {
          command = "${lib.getExe pkgs.lsp-ai}";
          config = {
            memory.file_story = { };
            models.model1 = {
              type = "open_ai";
              chat_endpoint = "https://api.githubcopilot.com/chat/completions";
              model = "gpt-4";
              auth_token_env_var_name = "COPILOT_API_KEY";
            };
            completion = {
              model = "model1";
              parameters = {
                max_token = 500;
                max_context = 1024;
              };
            };
          };
        };
      };
    };
  };
}
