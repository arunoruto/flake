# Pure functions for transforming development language data to Zed settings.
#
# Zed's per-language metadata is typed by `metaOptions` in ./default.nix and
# supplied by each languages/<lang>.nix under `consumerMeta.zed`.
#
# Languages arrive already filtered and resolved for the "zed" consumer (see
# ../registry.nix): capability-checked, so `consumerMeta.zed` is non-null for
# every one of them, with `lspServers`/`formatters` narrowed to what is enabled
# and exposed to Zed and the resolved registry entries attached as
# `lsps`/`formatterConfigs`.
{ lib }:
let
  zedMeta = language: language.consumerMeta.zed;

  # The curated server ids that name a real devix LSP (i.e. excluding the "..."
  # Zed-defaults marker) — these are the ones we emit a `lsp.<id>.binary` for.
  explicitServers = meta: builtins.filter (server: server != "...") meta.languageServers;

  formatterToZed = formatter: {
    external = {
      inherit (formatter) command;
      arguments = formatter.args;
    };
  };

  languageSetting =
    name: language:
    let
      meta = zedMeta language;
      formatters = map (
        formatterName: formatterToZed language.formatterConfigs.${formatterName}
      ) language.formatters;
    in
    lib.nameValuePair meta.name (
      {
        tab_size = language.tabWidth;
        hard_tabs = !language.insertSpaces;
      }
      // lib.optionalAttrs (meta.languageServers != [ ]) {
        language_servers = meta.languageServers;
      }
      // lib.optionalAttrs (formatters != [ ]) {
        formatter = if builtins.length formatters == 1 then builtins.head formatters else formatters;
        format_on_save = "on";
      }
    );

  # Per-LSP Zed settings (`lsp.<id>.binary` / `.settings`). Only servers that the
  # language explicitly lists in its curated `languageServers` get a binary
  # override; anything left to Zed's "..." defaults is not overridden.
  lspSettings =
    languages:
    lib.foldl' lib.recursiveUpdate { } (
      lib.mapAttrsToList (
        _: language:
        let
          meta = zedMeta language;
          named = explicitServers meta;
          emitted = lib.filterAttrs (lspName: _: builtins.elem lspName named) language.lsps;
        in
        lib.mapAttrs (
          _: lspOpts:
          {
            binary = {
              path = lspOpts.command;
            }
            // lib.optionalAttrs (lspOpts.args != [ ]) {
              arguments = lspOpts.args;
            };
          }
          // lib.optionalAttrs (lspOpts.config != { }) {
            settings = lspOpts.config;
          }
        ) emitted
      ) languages
    );

  toZedSettings =
    languages:
    let
      languagesSettings = builtins.listToAttrs (lib.mapAttrsToList languageSetting languages);
      lsp = lspSettings languages;
    in
    lib.optionalAttrs (languagesSettings != { }) { languages = languagesSettings; }
    // lib.optionalAttrs (lsp != { }) { inherit lsp; };

  extractExtensions =
    languages:
    lib.unique (lib.concatMap (language: (zedMeta language).extensions) (lib.attrValues languages));
in
{
  inherit
    toZedSettings
    extractExtensions
    ;
}
