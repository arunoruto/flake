{ pkgs, lib, ... }:
{
  programs.helix = {
    languages = {
      language-server = {
        lsp-ai = {
          command = "${lib.getExe pkgs.lsp-ai}";
          config = {
            memory.file_store = { };
            models.model1 = {
              type = "open_ai";
              chat_endpoint = "https://api.githubcopilot.com/chat/completions";
              completions_endpoint = "https://api.githubcopilot.com/chat/completions";
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
            chat = [
              {
                trigger = "!C";
                action_display_name = "Chat";
                model = "model1";
                parameters = {
                  max_token = 4096;
                  max_context = 1024;
                  system = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do you best to answer succinctly and accurately";
                };
              }
              {
                trigger = "!CC";
                action_display_name = "Chat with context";
                model = "model1";
                parameters = {
                  max_token = 4096;
                  max_context = 1024;
                  system = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do you best to answer succinctly and accurately given the code context:\n\n{CONTEXT}";
                };
              }
            ];
          };
        };
      };
    };
  };
}
