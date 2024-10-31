{ pkgs, ... }:
{
  programs.nixvim = {
    plugins = {
      lsp = {
        servers = {
          ltex = {
            enable = true;
            settings = {
              language = "en-US";
              ltex-ls.path = "${pkgs.ltex-ls}";
              additionalRules.languageModel = "~/.cache/ngrams";
            };
          };
        };
      };
    };
  };
}
