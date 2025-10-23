{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ty;
  settingsFormat = pkgs.formats.toml { };
in
{
  meta.maintainers = [ lib.maintainers.arunoruto ];

  options.programs.ty = {
    enable = lib.mkEnableOption "ty, an extremely fast Python type checker and language server, written in Rust. ";

    package = lib.mkPackageOption pkgs "ty" { nullable = true; };

    settings = lib.mkOption {
      type = settingsFormat.type;
      example = lib.literalExpression ''
        {
          src.root = "./src";
          environment.python = "./.venv";
          termina.output-format = "concise";
          rules = {
            index-out-of-bounds = "ignore";
          };
        }
      '';
      description = ''
        ty configuration.
        For available settings see <https://docs.astral.sh/ty/reference/configuration>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    xdg.configFile."ty/ty.toml".source = settingsFormat.generate "ty.toml" cfg.settings;
  };
}
