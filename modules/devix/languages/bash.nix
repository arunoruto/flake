{
  config,
  lib,
  pkgs,
  ...
}:

let
  bashLanguage = import ../lib/bash.nix { inherit lib pkgs; };
in
{
  options.development.languages.bash = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Bash development environment" // {
          default = false;
        };
        configureHelix = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        lspServers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = bashLanguage.language.lspServers;
        };
        formatters = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = bashLanguage.language.formatters;
        };
        tabWidth = lib.mkOption {
          type = lib.types.int;
          default = bashLanguage.language.tabWidth;
          visible = false;
          internal = true;
        };
        insertSpaces = lib.mkOption {
          type = lib.types.bool;
          default = bashLanguage.language.insertSpaces;
          visible = false;
          internal = true;
        };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.bash.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (
          fmtName: fmtValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${fmtName}.${optName} = lib.mkDefault optValue;
          }) fmtValue
        ) bashLanguage.formatters
      )
    )
  );
}
