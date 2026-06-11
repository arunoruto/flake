{
  config,
  lib,
  pkgs,
  ...
}:

let
  mdLanguage = import ../lib/markdown.nix { inherit lib pkgs; };
in
{
  options.development.languages.markdown = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Markdown development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = mdLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = mdLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = mdLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = mdLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.markdown.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) mdLanguage.lsps
      )
      ++ lib.flatten (
        lib.mapAttrsToList (fmtName: fmtValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${fmtName}.${optName} = lib.mkDefault optValue;
          }) fmtValue
        ) mdLanguage.formatters
      )
    )
  );
}
