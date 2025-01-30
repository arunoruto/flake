# Config copilot like helix-gpt? https://github.com/leona/helix-gpt/blob/master/src/providers/github.ts
{ pkgs, lib, ... }:
{
  programs.helix = {
    languages = {
      language-server = {
        lsp-ai = {
          command = "lsp-ai";
          args = [ "--use-seperate-log-file" ];
          config = rec {
            memory.file_store = { };
            models = {
              copilot = {
                type = "open_ai";
                chat_endpoint = "https://api.githubcopilot.com/chat/completions";
                # completions_endpoint = "https://copilot-proxy.githubusercontent.com/v1/engines/copilot-codex/completions";
                # completions_endpoint = "https://api.githubcopilot.com/v1/engines/copilot-codex/completions";
                # completions_endpoint = "https://api.githubcopilot.com/chat/completions";
                model = "";
                auth_token_env_var_name = "GH_AUTH_TOKEN";
              };
              deepseek-ollama =
                let
                  url = "madara.king-little.ts.net";
                in
                {
                  type = "ollama";
                  # model = "deepseek-r1:14b";
                  model = "deepseek-coder-v2:16b";
                  chat_endpoint = "http://${url}:11434/api/chat";
                  generate_endpoint = "http://${url}:11434/api/generate";
                };
            };

            completion = rec {
              # model = "copilot";
              model = "deepseek-ollama";
              parameters =
                {
                  max_token = 500;
                  max_context = 2048;
                }
                // lib.optionalAttrs (models.${model}.type == "ollama") {
                  options = {
                    num_predict = 32;
                  };
                }
                // lib.optionalAttrs (model == "copilot") {
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
            # chat =
            #   let
            #     # model = "copilot";
            #     model = "deepseek-ollama";
            #   in
            #   [
            #     {
            #       trigger = "!C";
            #       action_display_name = "Chat";
            #       inherit model;
            #       parameters = {
            #         max_token = 4096;
            #         max_context = 1024;
            #         messages = [
            #           {
            #             content = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do you best to answer succinctly and accurately";
            #             role = "system";
            #           }
            #         ];
            #       };
            #     }
            #     {
            #       trigger = "!CC";
            #       action_display_name = "Chat with context";
            #       inherit model;
            #       parameters = {
            #         max_token = 4096;
            #         max_context = 1024;
            #         messages = [
            #           {
            #             content = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do you best to answer succinctly and accurately given the code context:\n\n{CONTEXT}";
            #             role = "system";
            #           }
            #         ];
            #       };
            #     }
            #   ];
          };
        };
      };
    };
  };

  home.packages = with pkgs; [
    lsp-ai
  ];
}
