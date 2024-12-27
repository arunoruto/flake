{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ghostty;
  keyValue = pkgs.formats.keyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault { } " = ";
  };
in
{
  meta.maintainers = [ lib.maintainers.HeitorAugustoLN ];

  options.programs.ghostty = {
    enable = lib.mkEnableOption "ghostty";
    package = lib.mkPackageOption pkgs "ghostty" { };

    settings = lib.mkOption {
      inherit (keyValue) type;
      default = { };
      example = lib.literalExpression ''
        {
          theme = "catppuccin-mocha";
          font-size = 10;
        }
      '';
      description = ''
        Configuration written to $XDG_CONFIG_HOME/ghostty/config.
        See https://ghostty.org/docs/config/reference for more information.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."ghostty/config" = lib.mkIf (cfg.settings != { }) {
      source = keyValue.generate "ghostty-config" cfg.settings;
    };
  };
}
