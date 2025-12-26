{ pkgs, ... }:
{
  programs.dev.languages.matlab = {
    extensions = [ ".m" ];
    helix.fileTypes = [ "m" ];
    autoFormat = true;
    lspServers = [ "matlab-ls" ];

    helix.languageConfig = {
      scope = "source.m";
      comment-token = "%";
    };

    packages = with pkgs; [ matlab-language-server ];
  };
}
