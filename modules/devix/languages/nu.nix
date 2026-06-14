{
  config,
  lib,
  pkgs,
  ...
}:

let
  nuLanguage = import ../lib/nu.nix { inherit lib pkgs; };
in
{
  options.development.languages.nu = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Nushell development environment" // {
          default = false;
        };
        configureHelix = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        lspServers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = nuLanguage.language.lspServers;
        };
        formatters = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = nuLanguage.language.formatters;
        };
        tabWidth = lib.mkOption {
          type = lib.types.int;
          default = nuLanguage.language.tabWidth;
          visible = false;
          internal = true;
        };
        insertSpaces = lib.mkOption {
          type = lib.types.bool;
          default = nuLanguage.language.insertSpaces;
          visible = false;
          internal = true;
        };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.nu.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (
          fmtName: fmtValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${fmtName}.${optName} = lib.mkDefault optValue;
          }) fmtValue
        ) nuLanguage.formatters
      )
    )
  );
}
