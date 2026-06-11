{
  config,
  lib,
  pkgs,
  ...
}:

let
  yamlLanguage = import ../lib/yaml.nix { inherit lib pkgs; };
in
{
  options.development.languages.yaml = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "YAML development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = yamlLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = yamlLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = yamlLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = yamlLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.yaml.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) yamlLanguage.lsps
      )
      ++ lib.flatten (
        lib.mapAttrsToList (fmtName: fmtValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${fmtName}.${optName} = lib.mkDefault optValue;
          }) fmtValue
        ) yamlLanguage.formatters
      )
    )
  );
}
