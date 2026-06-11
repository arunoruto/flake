{
  config,
  lib,
  pkgs,
  ...
}:

let
  aiLanguage = import ../lib/ai.nix { inherit lib pkgs; };
in
{
  options.development.languages.ai = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "AI assistant environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = aiLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = aiLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = aiLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = aiLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.ai.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) aiLanguage.lsps
      )
    )
  );
}
