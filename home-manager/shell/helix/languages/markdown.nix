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
          # formatter.command = "alejandra";
          # formatter.command = "${pkgs.alejandra}/bin/alejandra";
          language-servers = ["marksman" "ltex"];
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
      marksman
      ltex-ls
    ];
  };
}