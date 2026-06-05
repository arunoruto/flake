# Language profile definitions for home-manager
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.devenv;
  pythonLanguage = import ../../devenv/lib/python.nix { inherit lib pkgs; };
in
{
  options.devenv.languages = {
    python = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Python development environment" // {
            default = false;
          };

          configureHelix = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Automatically configure Helix editor for Python.
              Only takes effect if both this language and helix are enabled.
            '';
          };

          # Inherit the actual language configuration structure
          # This mirrors the structure in devenv/profiles/python.nix
          lsps = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = pythonLanguage.lsps;
            visible = false;
            internal = true;
          };

          formatters = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = pythonLanguage.formatters;
            visible = false;
            internal = true;
          };

          tabWidth = lib.mkOption {
            type = lib.types.int;
            default = 4;
            visible = false;
            internal = true;
          };

          insertSpaces = lib.mkOption {
            type = lib.types.bool;
            default = true;
            visible = false;
            internal = true;
          };
        };
      };
      default = { };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.languages.python.enable {
        home.packages = [
          pkgs.pyright
          pkgs.ruff
        ];
      })
    ]
  );
}
