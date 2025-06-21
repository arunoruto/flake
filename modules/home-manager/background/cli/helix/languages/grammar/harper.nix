{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.helix.harper.enable = lib.mkEnableOption "Harper configuration for grammar";

  config = lib.mkIf config.helix.harper.enable {
    programs.helix = {
      languages.language-server.harper = {
        command = "harper-ls";
        args = [ "--stdio" ];

        config.harper-ls = {
          diagnosticSeverity = "hint";
          dialect = "American";
        };
      };
      extraPackages = with pkgs; [ unstable.harper ];
    };
  };
}
