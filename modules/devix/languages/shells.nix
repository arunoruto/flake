{
  config,
  lib,
  pkgs,
  ...
}:

let
  shellsLanguage = import ../lib/shells.nix { inherit lib pkgs; };
in
{
  options.development.languages.shells = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Shell development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = shellsLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = shellsLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = shellsLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = shellsLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.shells.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) shellsLanguage.lsps
      )
    )
  );
}
