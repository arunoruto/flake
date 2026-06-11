{
  config,
  lib,
  pkgs,
  ...
}:

let
  latexLanguage = import ../lib/latex.nix { inherit lib pkgs; };
in
{
  options.development.languages.latex = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "LaTeX development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = latexLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = latexLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = latexLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = latexLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.latex.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) latexLanguage.lsps
      )
    )
  );
}
