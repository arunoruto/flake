{ pkgs, lib, config, ... }:
{
  config = lib.mkIf (config.programs.dev.lsp.ltex.ngram.enable or false) {
    home.file = {
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
