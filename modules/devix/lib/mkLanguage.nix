# Generate a `development.languages.<name>` option module from the pure data in
# lib/<name>.nix. Collapses the otherwise-identical per-language modules into a
# single definition.
#
# Usage (languages/<name>.nix):
#   import ../lib/mkLanguage.nix {
#     name = "python";
#     libPath = ../lib/python.nix;
#     description = "Python development environment";
#   }
{
  name,
  libPath,
  description ? "${name} development environment",
  enableByDefault ? false,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  consumers = import ./consumers.nix { inherit lib; };
  data = import libPath { inherit lib pkgs; };
  meta = data.language;
  cfg = config.development.languages.${name};

  # Populate a shared registry (development.lsps / development.formatters) from
  # this language's data, every value as mkDefault so users can override.
  registryDefs =
    registry: items:
    lib.flatten (
      lib.mapAttrsToList (
        itemName: itemValue:
        lib.mapAttrsToList (optName: optValue: {
          development.${registry}.${itemName}.${optName} = lib.mkDefault optValue;
        }) itemValue
      ) items
    );
in
{
  options.development.languages.${name} = lib.mkOption {
    default = { };
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption description // {
          default = enableByDefault;
        };

        lspServers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = meta.lspServers;
          description = "Language servers (keys into development.lsps) used for ${name}.";
        };

        formatters = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = meta.formatters or [ ];
          description = "Formatters (keys into development.formatters) used for ${name}.";
        };

        consumers = consumers.mkExposureOption ''
          Per-consumer exposure for the ${name} language. Each consumer defaults
          to enabled; set e.g. `consumers.zed.enable = false` to skip ${name} in
          Zed only.
        '';

        tabWidth = lib.mkOption {
          type = lib.types.int;
          default = meta.tabWidth;
          visible = false;
          internal = true;
        };

        insertSpaces = lib.mkOption {
          type = lib.types.bool;
          default = meta.insertSpaces;
          visible = false;
          internal = true;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge (
      registryDefs "lsps" (data.lsps or { }) ++ registryDefs "formatters" (data.formatters or { })
    )
  );
}
