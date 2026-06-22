# Pure transforms: development languages -> OpenCode (opencode.json) settings.
#
# OpenCode attaches LSP servers and formatters to files by extension. A language
# is supported by OpenCode iff it carries `consumerMeta.opencode = { extensions }`
# (file-extension globs like ".py"). `mkCommand serverName lspOpts` builds the
# launcher command array — the home target supplies it so this stays pure (it
# wraps the command for env/secret setup when needed).
{ lib }:
let
  ocMeta = language: language.consumerMeta.opencode or null;
  supported = languages: lib.filterAttrs (_: language: ocMeta language != null) languages;

  # serverName -> file extensions aggregated across supported languages using it.
  extensionsByServer =
    languages:
    lib.foldl' (
      acc: language:
      let
        exts = (ocMeta language).extensions or [ ];
      in
      lib.foldl' (
        acc2: serverName: acc2 // { ${serverName} = lib.unique ((acc2.${serverName} or [ ]) ++ exts); }
      ) acc language.lspServers
    ) { } (lib.attrValues (supported languages));

  # Resolved LSP option-sets across supported languages, keyed by server name.
  lspOptsByServer =
    languages:
    lib.foldl' lib.recursiveUpdate { } (
      lib.mapAttrsToList (_: language: language.lsps) (supported languages)
    );

  toLspSettings =
    mkCommand: languages:
    let
      exts = extensionsByServer languages;
      opts = lspOptsByServer languages;
    in
    lib.mapAttrs (serverName: serverExts: {
      command = mkCommand serverName opts.${serverName};
      extensions = serverExts;
      env = opts.${serverName}.environment;
      initialization = opts.${serverName}.config;
    }) exts;

  # formatterName -> { command; extensions } aggregated across supported languages.
  toFormatterSettings =
    languages:
    lib.foldl' (
      acc: language:
      let
        exts = (ocMeta language).extensions or [ ];
      in
      lib.foldl' (
        acc2: formatterName:
        let
          fmt = language.formatterConfigs.${formatterName};
        in
        acc2
        // {
          ${formatterName} = {
            command = [ fmt.command ] ++ fmt.args;
            extensions = lib.unique (((acc2.${formatterName} or { }).extensions or [ ]) ++ exts);
          };
        }
      ) acc language.formatters
    ) { } (lib.attrValues (supported languages));

  toOpencodeSettings =
    mkCommand: languages:
    let
      lsp = toLspSettings mkCommand languages;
      formatter = toFormatterSettings languages;
    in
    lib.optionalAttrs (lsp != { }) { inherit lsp; }
    // lib.optionalAttrs (formatter != { }) { inherit formatter; };
in
{
  inherit toOpencodeSettings;
}
