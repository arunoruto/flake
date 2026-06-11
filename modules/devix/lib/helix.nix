# Pure functions for transforming development language data to Helix configuration
{ lib, bash ? "bash" }:

let
  resolveLanguages =
    cfg: languages:
    lib.mapAttrs (
      name: language:
      let
        lspServers = builtins.filter (lspName: cfg.lsps.${lspName}.enable) language.lspServers;
        formatters = builtins.filter (formatterName: cfg.formatters.${formatterName}.enable) language.formatters;
      in
      language
      // {
        inherit lspServers formatters;
        lsps = lib.genAttrs lspServers (lspName: cfg.lsps.${lspName});
        formatterConfigs = lib.genAttrs formatters (formatterName: cfg.formatters.${formatterName});
      }
    ) languages;

  # Extract all packages from enabled LSPs and formatters across resolved languages.
  extractPackages =
    languages:
    lib.unique (
      lib.flatten (
        lib.mapAttrsToList (
          langName: langOpts:
          (lib.mapAttrsToList (n: v: v.package) (
            lib.filterAttrs (n: v: v.enable && v.package != null) langOpts.lsps
          ))
          ++ (lib.mapAttrsToList (n: v: v.package) (
            lib.filterAttrs (n: v: v.enable && v.package != null) langOpts.formatterConfigs
          ))
        ) languages
      )
    );

  # Build formatter configuration (handles single or multiple formatters)
  buildFormatterConfig =
    formatterNames: formatterConfigs:
    let
      activeFormatters = map (formatterName: formatterConfigs.${formatterName}) formatterNames;
    in
    if builtins.length activeFormatters == 0 then
      null
    else if builtins.length activeFormatters == 1 then
      {
        command = (builtins.head activeFormatters).command;
        args = (builtins.head activeFormatters).args;
      }
    else
      {
        command = bash;
        args = [
          "-c"
          (lib.concatMapStringsSep " | " (f: "${f.command} ${lib.escapeShellArgs f.args}") activeFormatters)
        ];
      };

  # Transform a single language to Helix format
  transformLanguage =
    name: langOpts:
    let
      activeLsps = lib.filterAttrs (n: v: v.enable) langOpts.lsps;
      formatterConfig = buildFormatterConfig langOpts.formatters langOpts.formatterConfigs;
    in
    {
      inherit name;
      auto-format = formatterConfig != null;
      formatter = lib.mkIf (formatterConfig != null) formatterConfig;
      language-servers = lib.mkIf (activeLsps != { }) langOpts.lspServers;
      indent = {
        tab-width = langOpts.tabWidth;
        unit = if langOpts.insertSpaces then " " else "\t";
      };
    };

  # Transform all languages to Helix language array
  toHelixLanguages =
    languages:
    map (name: transformLanguage name languages.${name}) (
      lib.sort lib.lessThan (builtins.attrNames languages)
    );

  # Generate language-server configuration blocks
  toHelixLspConfigs =
    languages:
    let
      languageServers = lib.foldl' lib.recursiveUpdate { } (
        lib.mapAttrsToList (
          langName: langOpts:
          let
            activeLsps = lib.filterAttrs (n: v: v.enable) langOpts.lsps;
          in
          lib.mapAttrs (_: lspOpts: {
            command = lspOpts.command;
            args = lib.mkIf (lspOpts.args != [ ]) lspOpts.args;
            config = lib.mkIf (lspOpts.config != { }) lspOpts.config;
          }) activeLsps
        ) languages
      );
    in
    lib.optionalAttrs (languageServers != { }) {
      language-server = languageServers;
    };
in
{
  inherit
    extractPackages
    resolveLanguages
    toHelixLanguages
    toHelixLspConfigs
    buildFormatterConfig
    ;
}
