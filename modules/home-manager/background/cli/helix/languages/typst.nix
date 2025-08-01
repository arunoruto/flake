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
  options.helix.typst.enable = lib.mkEnableOption "Helix Typst config";

  config = lib.mkIf config.helix.typst.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "typst";
            auto-format = true;
            rulers = [ 120 ];
            language-servers =
              lib.optionals (ls ? ltex) [ "ltex" ]
              ++ [
                "tinymist"
              ]
              # ++ lib.optionals (ls ? lsp-ai) [ "lsp-ai" ]
              ++ lib.optionals (ls ? gpt) [ "gpt" ]
              # ++ lib.optionals (ls ? copilot) [ "copilot" ]
              ++ [ ];
            formatter.command = "typstyle";
            soft-wrap.enable = true;
          }
        ];
        language-server = {
          # oxide.command = "markdown-oxide";
          # iwe.command = "iwes";
        };
      };
      extraPackages = with pkgs; [
        tinymist
        typstyle
      ];
    };
  };
}
