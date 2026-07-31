# The devix consumer registry.
#
# A consumer is an editor/program (Helix, Zed, OpenCode, …) that consumes the
# language/LSP/formatter configuration and applies it for itself. Each consumer
# is one directory next to this file:
#
#   consumers/<name>/default.nix    the registry entry read here
#   consumers/<name>/transform.nix  pure data -> that consumer's config format
#   consumers/<name>/home.nix       the Home Manager adapter
#
# Adding an editor means adding that directory and nothing else: the consumer
# list, the `devix.consumers.<name>` options, the per-item exposure
# toggles, the `defaultEditor` enum and the EDITOR/VISUAL command map are all
# derived from the entries below.
#
# Two control surfaces decide what a consumer sees, and both are applied here
# rather than in the individual adapters:
#   - *exposure* — toggles on registry items (lsps/formatters), languages and
#     addons, all defaulting to `true` ("exposed unless opted out");
#   - *capability* — what the consumer can handle at all. Each entry declares
#     `capability = "all"` (configures languages generically) or `"meta"` (only
#     languages carrying `consumerMeta.<name>`, whose shape the entry types via
#     `metaOptions`).
{ lib }:
rec {
  # Consumer names, discovered from the directories next to this file.
  names = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.));

  # name -> { description; capability; metaOptions; activeWhen; editorCommand; home; }
  entries = lib.genAttrs names (
    name:
    let
      entry = import (./. + "/${name}");
    in
    if
      !(builtins.elem entry.capability [
        "all"
        "meta"
      ])
    then
      throw "devix consumer '${name}': capability must be \"all\" or \"meta\", got \"${entry.capability}\""
    else if entry.capability == "meta" && entry.metaOptions == null then
      throw "devix consumer '${name}': capability \"meta\" needs metaOptions to type its consumerMeta"
    else
      entry
  );

  # Home Manager adapter modules, one per consumer.
  homeModules = lib.mapAttrsToList (_: entry: entry.home) entries;

  # devenv adapter modules, for the consumers that have one. Zed and OpenCode
  # currently do not — adding `consumers/<name>/devenv.nix` is all it takes.
  devenvModules = lib.mapAttrsToList (_: entry: entry.devenv) (
    lib.filterAttrs (_: entry: entry.devenv != null) entries
  );

  # Consumers that can serve as `devix.defaultEditor`, mapped to the
  # command EDITOR/VISUAL should use. Consumers that are not general-purpose
  # editors (an AI harness, say) declare `editorCommand = null` and drop out.
  editorCommands = lib.mapAttrs (_: entry: entry.editorCommand) (
    lib.filterAttrs (_: entry: entry.editorCommand != null) entries
  );

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

  # Is item `entry` (an lsp/formatter/language/addon value carrying `.consumers`)
  # exposed to consumer `name`? Missing data defaults to exposed.
  exposedTo = name: entry: entry.consumers.${name}.enable or true;

  # Can `consumer` configure this language at all? Consumers declaring
  # `capability = "all"` handle anything; the rest need the language to carry
  # matching `consumerMeta`. This is the single place capability is decided —
  # adapters must not re-implement it.
  supports =
    consumer: language:
    entries.${consumer}.capability == "all" || (language.consumerMeta.${consumer} or null) != null;

  # Languages that are enabled, exposed to `consumer`, and supported by it.
  languagesFor =
    consumer: languages:
    lib.filterAttrs (
      _: language: language.enable && exposedTo consumer language && supports consumer language
    ) languages;

  # Enabled addons whose servers attach to `langName`. Tolerates a config that
  # imports no addons module at all (devenv profiles may compose only parts).
  addonsFor =
    cfg: langName:
    lib.filter (
      addon: addon.enable && (builtins.elem "*" addon.languages || builtins.elem langName addon.languages)
    ) (lib.attrValues (cfg.addons or { }));

  # Every LSP name an enabled language actually ends up using, addons included.
  # Consumer-independent — this is the set that needs installing.
  referencedLsps =
    cfg:
    lib.unique (
      lib.concatLists (
        lib.mapAttrsToList (
          langName: language:
          language.lspServers ++ lib.concatMap (addon: addon.lspServers) (addonsFor cfg langName)
        ) (lib.filterAttrs (_: language: language.enable) cfg.languages)
      )
    );

  # Resolve languages for `consumer`: extend each language's servers with those
  # its enabled addons contribute, keep only the LSPs and formatters that are
  # both enabled in the registry and exposed to the consumer, then attach the
  # resolved registry entries. Shared by every adapter so the per-consumer
  # filtering rules live in exactly one place.
  resolveForConsumer =
    consumer: cfg: languages:
    lib.mapAttrs (
      langName: language:
      let
        addonServers = lib.concatMap (addon: addon.lspServers) (
          lib.filter (exposedTo consumer) (addonsFor cfg langName)
        );
        # Names with no registry entry are dropped rather than dereferenced, so
        # a typo surfaces as the assertion in targets/home/packages.nix ("…
        # references unknown LSPs: x") instead of an opaque "attribute missing".
        lspServers = builtins.filter (
          lspName:
          cfg.lsps ? ${lspName} && cfg.lsps.${lspName}.enable && exposedTo consumer cfg.lsps.${lspName}
        ) (lib.unique (language.lspServers ++ addonServers));
        formatters = builtins.filter (
          formatterName:
          cfg.formatters ? ${formatterName}
          && cfg.formatters.${formatterName}.enable
          && exposedTo consumer cfg.formatters.${formatterName}
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
