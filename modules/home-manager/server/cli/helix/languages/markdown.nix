# How to set up markdown in helix: https://medium.com/@CaffeineForCode/helix-setup-for-markdown-b29d9891a812
# ltex for markdown in helix: https://github.com/helix-editor/helix/issues/1942
{
  config,
  lib,
  pkgs,
  ...
}:
let
  ls = config.programs.helix.languages.language-server;
in
{
  options.helix.markdown.enable = lib.mkEnableOption "Helix Markdown config";

  config = lib.mkIf config.helix.markdown.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "markdown";
            auto-format = true;
            rulers = [ 120 ];
            language-servers =
              # lib.optionals config.helix.ltex.enable [
              lib.optionals (ls ? ltex) [
                "ltex"
              ]
              ++ [
                "marksman"
                "oxide"
              ]
              ++ lib.optionals (ls ? gpt) [
                "gpt"
              ];
            # ++ lib.optionals (ls ? lsp-ai) [
            #   "lsp-ai"
            # ];
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "markdown"
              ];
            };
            # formatter = {
            #   command = "dprint";
            #   args = ["--config" "~/.config/dprint.jsonc" "fmt" "--stdin" "md"];
            # };
          }
        ];
        language-server = {
          oxide = {
            command = lib.getExe pkgs.markdown-oxide;
          };
        };
      };
      extraPackages = with pkgs; [
        marksman
        nodePackages.prettier
      ];
    };
  };
}
