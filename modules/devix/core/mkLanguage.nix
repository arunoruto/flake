# Turn the pure data in languages/<name>.nix into a
# `devix.languages.<name>` option module. Called once per data file by
# languages/default.nix, so adding a language is adding that one file.
{
  name,
  dataPath,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  consumers = import ../consumers/registry.nix { inherit lib; };
  data = import dataPath { inherit lib pkgs; };
  meta = data.language;
  cfg = config.devix.languages.${name};

  # Consumers that need per-language metadata to configure anything.
  metaConsumers = lib.filterAttrs (_: entry: entry.metaOptions != null) consumers.entries;

  # Populate a shared registry (devix.lsps / devix.formatters) from
  # this language's data, every value as mkDefault so users can override.
  registryDefs =
    registry: items:
    lib.flatten (
      lib.mapAttrsToList (
        itemName: itemValue:
        lib.mapAttrsToList (optName: optValue: {
          devix.${registry}.${itemName}.${optName} = lib.mkDefault optValue;
        }) itemValue
      ) items
    );
in
{
  options.devix.languages.${name} = lib.mkOption {
    default = { };
    description = ''
      Settings for ${name} (${data.description or "${name} development environment"}).
      Every value below is defaulted from `modules/devix/languages/${name}.nix`,
      so you only need to set what you want to change.
    '';
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption (data.description or "${name} development environment");

        lspServers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = meta.lspServers;
          description = "Language servers (keys into devix.lsps) used for ${name}.";
        };

        formatters = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = meta.formatters or [ ];
          description = "Formatters (keys into devix.formatters) used for ${name}.";
        };

        consumers = consumers.mkExposureOption ''
          Per-consumer exposure for the ${name} language. Each consumer defaults
          to enabled; set e.g. `consumers.zed.enable = false` to skip ${name} in
          Zed only.
        '';

        consumerMeta = lib.mkOption {
          type = lib.types.submodule {
            options = lib.mapAttrs (
              consumerName: entry:
              lib.mkOption {
                type = lib.types.nullOr (lib.types.submodule { options = entry.metaOptions lib; });
                default = data.consumerMeta.${consumerName} or null;
                description = ''
                  How the ${consumerName} consumer handles ${name}. `null` means
                  ${consumerName} cannot configure this language and skips it.
                '';
              }
            ) metaConsumers;
          };
          default = { };
          description = ''
            Per-consumer metadata for ${name}, defaulted from
            languages/${name}.nix. Only consumers that need metadata appear
            here; each one types its own shape (see the consumer's
            `metaOptions` in consumers/<name>/default.nix).
          '';
        };

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

        roots = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          default = meta.roots or null;
          description = "Root files for workspace detection (e.g. Cargo.toml for Rust).";
          visible = false;
          internal = true;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge (
      registryDefs "lsps" (data.lsps or { })
      ++ registryDefs "formatters" (data.formatters or { })
      ++ lib.optionals (data ? packages) [
        { home.packages = data.packages; }
      ]
    )
  );
}
