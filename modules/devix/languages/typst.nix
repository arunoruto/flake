{
  config,
  lib,
  pkgs,
  ...
}:

let
  typstLanguage = import ../lib/typst.nix { inherit lib pkgs; };
in
{
  options.development.languages.typst = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Typst development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = typstLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = typstLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = typstLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = typstLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.typst.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) typstLanguage.lsps
      )
      ++ lib.flatten (
        lib.mapAttrsToList (fmtName: fmtValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${fmtName}.${optName} = lib.mkDefault optValue;
          }) fmtValue
        ) typstLanguage.formatters
      )
    )
  );
}
