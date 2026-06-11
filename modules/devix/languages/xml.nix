{
  config,
  lib,
  pkgs,
  ...
}:

let
  xmlLanguage = import ../lib/xml.nix { inherit lib pkgs; };
in
{
  options.development.languages.xml = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "XML development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = xmlLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = xmlLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = xmlLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = xmlLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.xml.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) xmlLanguage.lsps
      )
    )
  );
}
