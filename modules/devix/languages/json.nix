{
  config,
  lib,
  pkgs,
  ...
}:

let
  jsonLanguage = import ../lib/json.nix { inherit lib pkgs; };
in
{
  options.development.languages.json = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "JSON development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = jsonLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = jsonLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = jsonLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = jsonLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.json.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) jsonLanguage.lsps
      )
      ++ lib.flatten (
        lib.mapAttrsToList (fmtName: fmtValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${fmtName}.${optName} = lib.mkDefault optValue;
          }) fmtValue
        ) jsonLanguage.formatters
      )
    )
  );
}
