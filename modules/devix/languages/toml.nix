{
  config,
  lib,
  pkgs,
  ...
}:

let
  tomlLanguage = import ../lib/toml.nix { inherit lib pkgs; };
in
{
  options.development.languages.toml = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "TOML development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = tomlLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = tomlLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = tomlLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = tomlLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.toml.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) tomlLanguage.lsps
      )
      ++ lib.flatten (
        lib.mapAttrsToList (fmtName: fmtValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${fmtName}.${optName} = lib.mkDefault optValue;
          }) fmtValue
        ) tomlLanguage.formatters
      )
    )
  );
}
