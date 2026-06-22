# Pure functions for transforming development language data to Zed settings.
#
# Zed-specific per-language metadata (display name, extensions to install,
# optional devix-LSP-name -> Zed-adapter-id remapping) lives in each
# lib/<lang>.nix under `consumerMeta.zed`. A language without that metadata is
# simply not supported by Zed and is skipped.
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

  # Map a devix LSP registry name to its Zed language-server adapter id
  # (identity unless the language overrides it via lspAdapters).
  zedAdapterId = meta: name: meta.lspAdapters.${name} or name;

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
      adapterIds = map (zedAdapterId meta) language.lspServers;
      formatters = map (
        formatterName: formatterToZed language.formatterConfigs.${formatterName}
      ) language.formatters;
    in
    lib.nameValuePair meta.name (
      {
        tab_size = language.tabWidth;
        hard_tabs = !language.insertSpaces;
      }
      // lib.optionalAttrs (adapterIds != [ ]) {
        language_servers = adapterIds;
      }
      // lib.optionalAttrs (formatters != [ ]) {
        formatter = if builtins.length formatters == 1 then builtins.head formatters else formatters;
        format_on_save = "on";
      }
    );

  # Per-LSP Zed settings (`lsp.<adapter-id>.binary` / `.settings`).
  lspSettings =
    languages:
    lib.foldl' lib.recursiveUpdate { } (
      lib.mapAttrsToList (
        _: language:
        let
          meta = zedMeta language;
        in
        lib.mapAttrs' (
          lspName: lspOpts:
          lib.nameValuePair (zedAdapterId meta lspName) (
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
          )
        ) language.lsps
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
