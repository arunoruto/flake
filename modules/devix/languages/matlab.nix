{
  config,
  lib,
  pkgs,
  ...
}:

let
  matlabLanguage = import ../lib/matlab.nix { inherit lib pkgs; };
in
{
  options.development.languages.matlab = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "MATLAB development environment" // { default = false; };
        configureHelix = lib.mkOption { type = lib.types.bool; default = true; };
        lspServers = lib.mkOption { type = lib.types.listOf lib.types.str; default = matlabLanguage.language.lspServers; };
        formatters = lib.mkOption { type = lib.types.listOf lib.types.str; default = matlabLanguage.language.formatters; };
        tabWidth = lib.mkOption { type = lib.types.int; default = matlabLanguage.language.tabWidth; visible = false; internal = true; };
        insertSpaces = lib.mkOption { type = lib.types.bool; default = matlabLanguage.language.insertSpaces; visible = false; internal = true; };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.matlab.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) matlabLanguage.lsps
      )
    )
  );
}
