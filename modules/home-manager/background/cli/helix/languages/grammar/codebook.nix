{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.helix.codebook.enable = lib.mkEnableOption "Codebook configuration for grammar";

  config = lib.mkIf config.helix.codebook.enable {
    programs.helix = {
      languages.language-server.codebook = {
        command = "codebook-lsp";
        args = [ "serve" ];
      };
      extraPackages = with pkgs; [ unstable.codebook ];
    };
  };
}
