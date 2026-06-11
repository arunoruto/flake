{
  config,
  lib,
  pkgs,
  ...
}:

let
  juliaLanguage = import ../lib/julia.nix { inherit lib pkgs; };
in
{
  options.development.languages.julia = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Julia development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = juliaLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = juliaLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = juliaLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = juliaLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.julia.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) juliaLanguage.lsps
      )
    )
  );
}
