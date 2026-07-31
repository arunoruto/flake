# Pure transforms: development languages -> OpenCode (opencode.json) settings.
#
# OpenCode attaches LSP servers and formatters to files by extension, which it
# learns from `consumerMeta.opencode.extensions` (typed by `metaOptions` in
# ./default.nix). `mkCommand serverName lspOpts` builds the launcher command
# array — the home target supplies it so this stays pure (it wraps the command
# for env/secret setup when needed).
#
# Languages arrive already filtered and resolved for the "opencode" consumer
# (see ../registry.nix), so `consumerMeta.opencode` is non-null throughout.
{ lib }:
let
  ocMeta = language: language.consumerMeta.opencode;

  # serverName -> file extensions aggregated across the languages using it.
  extensionsByServer =
    languages:
    lib.foldl' (
      acc: language:
      let
        inherit ((ocMeta language)) extensions;
      in
      lib.foldl' (
        acc2: serverName:
        acc2 // { ${serverName} = lib.unique ((acc2.${serverName} or [ ]) ++ extensions); }
      ) acc language.lspServers
    ) { } (lib.attrValues languages);

  # Resolved LSP option-sets across the languages, keyed by server name.
  lspOptsByServer =
    languages:
    lib.foldl' lib.recursiveUpdate { } (lib.mapAttrsToList (_: language: language.lsps) languages);

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

  # formatterName -> { command; extensions } aggregated across the languages.
  toFormatterSettings =
    languages:
    lib.foldl' (
      acc: language:
      let
        exts = (ocMeta language).extensions;
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
    ) { } (lib.attrValues languages);

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
