{
  config,
  lib,
  pkgs,
  ...
}:

let
  pythonLanguage = import ../lib/python.nix { inherit lib pkgs; };
in
{
  options.development.languages.python = lib.mkOption {
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
            Only takes effect if Python and Helix integration are enabled.
          '';
        };

        lspServers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = pythonLanguage.language.lspServers;
          description = "Language servers from development.lsps used for Python.";
        };

        formatters = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = pythonLanguage.language.formatters;
          description = "Formatters from development.formatters used for Python.";
        };

        tabWidth = lib.mkOption {
          type = lib.types.int;
          default = pythonLanguage.language.tabWidth;
          visible = false;
          internal = true;
        };

        insertSpaces = lib.mkOption {
          type = lib.types.bool;
          default = pythonLanguage.language.insertSpaces;
          visible = false;
          internal = true;
        };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.python.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) pythonLanguage.lsps
      )
      ++ lib.flatten (
        lib.mapAttrsToList (formatterName: formatterValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${formatterName}.${optName} = lib.mkDefault optValue;
          }) formatterValue
        ) pythonLanguage.formatters
      )
    )
  );
}
