# Pure functions for transforming development language data to Zed settings.
#
# Zed-specific per-language metadata lives in each lib/<lang>.nix under
# `consumerMeta.zed`:
#   - name           : Zed's display name for the language (settings key).
#   - extensions     : Zed extensions to install for the language.
#   - languageServers: the curated, ordered `language_servers` list Zed should
#                      use. May contain the literal "..." token (Zed's "then the
#                      defaults" marker) and deliberately omits devix servers
#                      that Zed handles better with its own built-ins.
# A language without that metadata is simply not supported by Zed and is skipped.
#
# Languages are expected to arrive already resolved for the "zed" consumer
# (see lib/consumers.nix `resolveForConsumer`), i.e. `lspServers`/`formatters`
# are filtered to those enabled and exposed to Zed, with the resolved registry
# entries attached as `lsps`/`formatterConfigs`.
{ lib }:
let
  zedMeta = language: language.consumerMeta.zed or null;

  # Only languages that carry Zed metadata are supported by Zed (capability).
  supported = languages: lib.filterAttrs (_: language: zedMeta language != null) languages;

  # The curated server ids that name a real devix LSP (i.e. excluding the "..."
  # Zed-defaults marker) — these are the ones we emit a `lsp.<id>.binary` for.
  explicitServers = meta: builtins.filter (server: server != "...") meta.languageServers;

  formatterToZed = formatter: {
    external = {
      command = formatter.command;
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
      supportedLanguages = supported languages;
      languagesSettings = builtins.listToAttrs (lib.mapAttrsToList languageSetting supportedLanguages);
      lsp = lspSettings supportedLanguages;
    in
    lib.optionalAttrs (languagesSettings != { }) { languages = languagesSettings; }
    // lib.optionalAttrs (lsp != { }) { inherit lsp; };

  extractExtensions =
    languages:
    lib.unique (
      lib.concatMap (language: (zedMeta language).extensions or [ ]) (
        lib.attrValues (supported languages)
      )
    );
in
{
  inherit
    toZedSettings
    extractExtensions
    ;
}
