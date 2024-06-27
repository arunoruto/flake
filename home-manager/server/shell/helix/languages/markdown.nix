# How to set up markdown in helix: https://medium.com/@CaffeineForCode/helix-setup-for-markdown-b29d9891a812
# ltex for markdown in helix: https://github.com/helix-editor/helix/issues/1942
{pkgs, ...}: {
  programs.helix = {
    languages = {
      language = [
        {
          name = "markdown";
          auto-format = true;
          rulers = [120];
          # language-servers = ["marksman" "ltex"];
          language-servers = ["marksman"];
          formatter = {
            command = "prettier";
            args = ["--parser" "markdown"];
          };
          # formatter = {
          #   command = "dprint";
          #   args = ["--config" "~/.config/dprint.jsonc" "fmt" "--stdin" "md"];
          # };
        }
      ];
      language-server = {
        ltex = {
          command = "ltex-ls";
          config.ltex.dictionary = {
            "en-US" = [];
          };
        };
      };
    };
    extraPackages = with pkgs; [
      # ltex-ls
      marksman
      nodePackages.prettier
    ];
  };
}
