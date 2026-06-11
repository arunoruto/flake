{
  config,
  lib,
  pkgs,
  ...
}:

let
  grammarLanguage = import ../lib/grammar.nix { inherit lib pkgs; };
in
{
  options.development.languages.grammar = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Grammar checking environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = grammarLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = grammarLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = grammarLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = grammarLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.grammar.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) grammarLanguage.lsps
      )
    )
  );
}
