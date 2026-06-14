{
  config,
  lib,
  pkgs,
  ...
}:

let
  fishLanguage = import ../lib/fish.nix { inherit lib pkgs; };
in
{
  options.development.languages.fish = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Fish development environment" // {
          default = false;
        };
        configureHelix = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        lspServers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = fishLanguage.language.lspServers;
        };
        formatters = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = fishLanguage.language.formatters;
        };
        tabWidth = lib.mkOption {
          type = lib.types.int;
          default = fishLanguage.language.tabWidth;
          visible = false;
          internal = true;
        };
        insertSpaces = lib.mkOption {
          type = lib.types.bool;
          default = fishLanguage.language.insertSpaces;
          visible = false;
          internal = true;
        };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.fish.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (
          lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) fishLanguage.lsps
      )
      ++ lib.flatten (
        lib.mapAttrsToList (
          fmtName: fmtValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${fmtName}.${optName} = lib.mkDefault optValue;
          }) fmtValue
        ) fishLanguage.formatters
      )
    )
  );
}
