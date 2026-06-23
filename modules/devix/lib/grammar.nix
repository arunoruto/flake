{ lib, pkgs }:

{
  lsps = {
    ltex = {
      enable = true;
      package = pkgs.ltex-ls-plus;
      command = "ltex-ls-plus";
      config.ltex.language = "en-GB";
    };

    harper = {
      enable = true;
      package = pkgs.harper;
      command = lib.getExe pkgs.harper;
    };

    codebook = {
      enable = true;
      package = pkgs.codebook;
      command = lib.getExe pkgs.codebook;
    };
  };

  formatters = { };

  language = {
    lspServers = [
      "ltex"
      "harper"
      "codebook"
    ];
    formatters = [ ];
    tabWidth = 2;
    insertSpaces = true;
  };
}
