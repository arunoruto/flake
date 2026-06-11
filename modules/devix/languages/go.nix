{
  config,
  lib,
  pkgs,
  ...
}:

let
  goLanguage = import ../lib/go.nix { inherit lib pkgs; };
in
{
  options.development.languages.go = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Go development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = goLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = goLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = goLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = goLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.go.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) goLanguage.lsps
      )
      ++ lib.flatten (
        lib.mapAttrsToList (fmtName: fmtValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${fmtName}.${optName} = lib.mkDefault optValue;
          }) fmtValue
        ) goLanguage.formatters
      )
    )
  );
}
