# Pure functions for transforming devenv language data to Helix configuration
{ lib }:

let
  # Extract all packages from enabled LSPs and formatters across all languages
  extractPackages = languages:
    lib.flatten (
      lib.mapAttrsToList (
        langName: langOpts:
        (lib.mapAttrsToList (n: v: v.package) (
          lib.filterAttrs (n: v: v.enable && v.package != null) langOpts.lsps
        ))
        ++ (lib.mapAttrsToList (n: v: v.package) (
          lib.filterAttrs (n: v: v.enable && v.package != null) langOpts.formatters
        ))
      ) languages
    );

  # Build formatter configuration (handles single or multiple formatters)
  buildFormatterConfig = formatters:
    let
      activeFormatters = lib.attrValues (lib.filterAttrs (n: v: v.enable) formatters);
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
        command = "bash";
        args = [
          "-c"
          (lib.concatMapStringsSep " | " (
            f: "${f.command} ${lib.escapeShellArgs f.args}"
          ) activeFormatters)
        ];
      };

  # Transform a single language to Helix format
  transformLanguage = name: langOpts:
    let
      activeLsps = lib.filterAttrs (n: v: v.enable) langOpts.lsps;
      formatterConfig = buildFormatterConfig langOpts.formatters;
    in
    {
      inherit name;
      auto-format = formatterConfig != null;
      formatter = lib.mkIf (formatterConfig != null) formatterConfig;
      language-servers = lib.mkIf (activeLsps != { }) (lib.attrNames activeLsps);
      indent = {
        tab-width = langOpts.tabWidth;
        unit = if langOpts.insertSpaces then " " else "\t";
      };
    };

  # Transform all languages to Helix language array
  toHelixLanguages = languages:
    lib.mapAttrsToList transformLanguage languages;

  # Generate language-server configuration blocks
  toHelixLspConfigs = languages:
    lib.foldl' lib.recursiveUpdate { } (
      lib.mapAttrsToList (
        langName: langOpts:
        let
          activeLsps = lib.filterAttrs (n: v: v.enable) langOpts.lsps;
        in
        lib.mapAttrs' (
          lspName: lspOpts:
          lib.nameValuePair "language-server.${lspName}" {
            command = lspOpts.command;
            args = lib.mkIf (lspOpts.args != [ ]) lspOpts.args;
            config = lib.mkIf (lspOpts.config != { }) lspOpts.config;
          }
        ) activeLsps
      ) languages
    );
in
{
  inherit extractPackages toHelixLanguages toHelixLspConfigs buildFormatterConfig;
}
