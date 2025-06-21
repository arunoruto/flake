# How to set up markdown in helix: https://medium.com/@CaffeineForCode/helix-setup-for-markdown-b29d9891a812
# ltex for markdown in helix: https://github.com/helix-editor/helix/issues/1942
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.helix.ltex = {
    enable = lib.mkEnableOption "LTeX configuration for grammar";
    ngram = lib.mkEnableOption "Setup ngrams for even better grammar correction";
  };

  config = lib.mkIf config.helix.ltex.enable {
    programs.helix = {
      languages.language-server.ltex = {
        command = "ltex-ls-plus";
        config.ltex = {
          language = "en-GB";
          # dictionary = {
          #   "en-US" = [ ];
          # };
          additionalRules.languageModel = lib.optionalString config.helix.ltex.ngram "${config.home.homeDirectory}/.cache/ngrams";
        };
      };
      extraPackages = with pkgs; [ unstable.ltex-ls-plus ];
    };

    home.file = lib.mkIf config.helix.ltex.ngram {
      ".cache/ngrams/de".source = pkgs.fetchzip {
        url = "https://languagetool.org/download/ngram-data/ngrams-de-20150819.zip";
        hash = "sha256-b+dPqDhXZQpVOGwDJOO4bFTQ15hhOSG6WPCx8RApfNg=";
      };
      ".cache/ngrams/en".source = pkgs.fetchzip {
        url = "https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip";
        hash = "sha256-v3Ym6CBJftQCY5FuY6s5ziFvHKAyYD3fTHr99i6N8sE=";
      };
    };
  };
}
