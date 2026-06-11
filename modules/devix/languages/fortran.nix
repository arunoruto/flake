{
  config,
  lib,
  pkgs,
  ...
}:

let
  fortranLanguage = import ../lib/fortran.nix { inherit lib pkgs; };
in
{
  options.development.languages.fortran = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Fortran development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = fortranLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = fortranLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = fortranLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = fortranLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.fortran.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) fortranLanguage.lsps
      )
      ++ lib.flatten (
        lib.mapAttrsToList (fmtName: fmtValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${fmtName}.${optName} = lib.mkDefault optValue;
          }) fmtValue
        ) fortranLanguage.formatters
      )
    )
  );
}
