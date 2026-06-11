{
  config,
  lib,
  pkgs,
  ...
}:

let
  nixLanguage = import ../lib/nix.nix { inherit lib pkgs; };
in
{
  options.development.languages.nix = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Nix development environment" // {
          default = false;
        };

        configureHelix = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Automatically configure Helix editor for Nix.
            Only takes effect if Nix and Helix integration are enabled.
          '';
        };

        lspServers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = nixLanguage.language.lspServers;
          description = "Language servers from development.lsps used for Nix.";
        };

        formatters = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = nixLanguage.language.formatters;
          description = "Formatters from development.formatters used for Nix.";
        };

        tabWidth = lib.mkOption {
          type = lib.types.int;
          default = nixLanguage.language.tabWidth;
          visible = false;
          internal = true;
        };

        insertSpaces = lib.mkOption {
          type = lib.types.bool;
          default = nixLanguage.language.insertSpaces;
          visible = false;
          internal = true;
        };
      };
    };
    default = { };
  };

  config = lib.mkIf config.development.languages.nix.enable (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (lspName: lspValue:
          lib.mapAttrsToList (optName: optValue: {
            development.lsps.${lspName}.${optName} = lib.mkDefault optValue;
          }) lspValue
        ) nixLanguage.lsps
      )
      ++ lib.flatten (
        lib.mapAttrsToList (formatterName: formatterValue:
          lib.mapAttrsToList (optName: optValue: {
            development.formatters.${formatterName}.${optName} = lib.mkDefault optValue;
          }) formatterValue
        ) nixLanguage.formatters
      )
    )
  );
}
