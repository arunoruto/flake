# Shared definitions for the devix "consumer" concept.
#
# A consumer is an editor/program (Helix, Zed, OpenCode, …) that consumes the
# language/LSP/formatter configuration and applies it for itself.
#
# Two control surfaces use the per-consumer toggle built here:
#   - exposure toggles on registry items (lsps/formatters) and on languages,
#     all default `true` ("exposed unless opted out");
#   - the adapters additionally filter by *capability* (what a consumer can
#     actually handle), derived from per-language metadata in lib/<lang>.nix.
{ lib }:
rec {
  # The set of known consumers. Add a new editor/program here and implement its
  # adapter under targets/home/<name>.nix (+ lib/<name>.nix).
  names = [
    "helix"
    "zed"
    "opencode"
  ];

  # A single `{ enable = <bool>; }` toggle, defaulting to exposed.
  exposureToggle = lib.types.submodule {
    options.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether this is exposed to / configured for this consumer.";
    };
  };

  # Build a `consumers = { helix = { enable = …; }; zed = …; … }` option where
  # every known consumer is present and defaults to exposed.
  mkExposureOption =
    description:
    lib.mkOption {
      type = lib.types.submodule {
        options = lib.genAttrs names (
          name:
          lib.mkOption {
            type = exposureToggle;
            default = { };
            description = "Exposure toggle for the ${name} consumer.";
          }
        );
      };
      default = { };
      inherit description;
    };

  # Is item `entry` (an lsp/formatter/language value carrying `.consumers`)
  # exposed to consumer `name`? Missing data defaults to exposed.
  exposedTo = name: entry: entry.consumers.${name}.enable or true;

  # Languages that are enabled AND exposed to `consumer`.
  languagesFor =
    consumer: languages: lib.filterAttrs (_: lang: lang.enable && exposedTo consumer lang) languages;

  # Resolve languages for `consumer`: within each language keep only the LSPs and
  # formatters that are both enabled in the registry and exposed to the consumer,
  # then attach the resolved registry entries. Shared by every adapter so the
  # per-consumer filtering rules live in exactly one place.
  resolveForConsumer =
    consumer: cfg: languages:
    lib.mapAttrs (
      _: language:
      let
        lspServers = builtins.filter (
          lspName: cfg.lsps.${lspName}.enable && exposedTo consumer cfg.lsps.${lspName}
        ) language.lspServers;
        formatters = builtins.filter (
          formatterName:
          cfg.formatters.${formatterName}.enable && exposedTo consumer cfg.formatters.${formatterName}
        ) language.formatters;
      in
      language
      // {
        inherit lspServers formatters;
        lsps = lib.genAttrs lspServers (lspName: cfg.lsps.${lspName});
        formatterConfigs = lib.genAttrs formatters (formatterName: cfg.formatters.${formatterName});
      }
    ) languages;
}
