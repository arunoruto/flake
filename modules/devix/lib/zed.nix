# Pure functions for transforming development language data to Zed settings
{ lib }:

let
  zedLanguages = {
    bash = {
      name = "Shell Script";
      extensions = [ ];
      lspServers = [ "..." ];
    };
    fish = {
      name = "Fish";
      extensions = [ "fish" ];
      lspServers = [
        "fish-lsp"
        "..."
      ];
    };
    fortran = {
      name = "Fortran";
      extensions = [ "fortran" ];
      lspServers = [
        "fortls"
        "..."
      ];
    };
    go = {
      name = "Go";
      extensions = [ ];
      lspServers = [
        "gopls"
        "..."
      ];
    };
    json = {
      name = "JSON";
      extensions = [ ];
      lspServers = [ "..." ];
    };
    latex = {
      name = "LaTeX";
      extensions = [ "latex" ];
      lspServers = [
        "texlab"
        "..."
      ];
    };
    markdown = {
      name = "Markdown";
      extensions = [ ];
      lspServers = [ "..." ];
    };
    matlab = {
      name = "Matlab";
      extensions = [ "matlab" ];
      lspServers = [
        "matlab-ls"
        "..."
      ];
    };
    nix = {
      name = "Nix";
      extensions = [ "nix" ];
      lspServers = [
        "nil"
        "nixd"
        "..."
      ];
    };
    nu = {
      name = "Nu";
      extensions = [ "nu" ];
      lspServers = [ "..." ];
    };
    python = {
      name = "Python";
      extensions = [ ];
      lspServers = [
        "pyright"
        "..."
      ];
    };
    toml = {
      name = "TOML";
      extensions = [ ];
      lspServers = [
        "taplo"
        "..."
      ];
    };
    typst = {
      name = "Typst";
      extensions = [ "typst" ];
      lspServers = [
        "tinymist"
        "..."
      ];
    };
    xml = {
      name = "XML";
      extensions = [ "xml" ];
      lspServers = [
        "lemminx"
        "..."
      ];
    };
    yaml = {
      name = "YAML";
      extensions = [ ];
      lspServers = [
        "yaml-lsp"
        "..."
      ];
    };
  };

  knownZedAdapters = lib.unique (
    lib.flatten (lib.mapAttrsToList (_: meta: meta.lspServers) zedLanguages)
  );
  knownZedAdapterNames = builtins.filter (name: name != "...") knownZedAdapters;

  resolveLanguages =
    cfg: languages:
    lib.mapAttrs (
      name: language:
      let
        lspServers = builtins.filter (lspName: cfg.lsps.${lspName}.enable) language.lspServers;
        formatters = builtins.filter (
          formatterName: cfg.formatters.${formatterName}.enable
        ) language.formatters;
      in
      language
      // {
        inherit lspServers formatters;
        lsps = lib.genAttrs lspServers (lspName: cfg.lsps.${lspName});
        formatterConfigs = lib.genAttrs formatters (formatterName: cfg.formatters.${formatterName});
      }
    ) languages;

  languageMeta = name: zedLanguages.${name} or null;

  formatterConfig = formatter: {
    external = {
      command = formatter.command;
      arguments = formatter.args;
    };
  };

  zedLspServers = language: (languageMeta language).lspServers or [ "..." ];

  languageSettings =
    name: language:
    let
      meta = languageMeta name;
      formatters = map (
        formatterName: formatterConfig language.formatterConfigs.${formatterName}
      ) language.formatters;
    in
    lib.nameValuePair meta.name (
      {
        tab_size = language.tabWidth;
        hard_tabs = !language.insertSpaces;
      }
      // lib.optionalAttrs (meta.lspServers != [ ]) {
        language_servers = meta.lspServers;
      }
      // lib.optionalAttrs (formatters != [ ]) {
        formatter = if builtins.length formatters == 1 then builtins.head formatters else formatters;
        format_on_save = "on";
      }
    );

  lspSettings =
    languages:
    let
      allLsps = lib.foldl' lib.recursiveUpdate { } (
        lib.mapAttrsToList (
          langName: langOpts:
          let
            activeLsps = lib.filterAttrs (n: v: v.enable) langOpts.lsps;
            knownLsps = lib.filterAttrs (n: _: builtins.elem n knownZedAdapterNames) activeLsps;
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
          ) knownLsps
        ) languages
      );
    in
    allLsps;

  toZedSettings =
    languages:
    let
      supportedLanguages = lib.filterAttrs (name: language: languageMeta name != null) languages;
      languagesSettings = builtins.listToAttrs (
        map (name: languageSettings name supportedLanguages.${name}) (
          lib.sort lib.lessThan (builtins.attrNames supportedLanguages)
        )
      );
      lsp = lspSettings supportedLanguages;
    in
    lib.optionalAttrs (languagesSettings != { }) { languages = languagesSettings; }
    // lib.optionalAttrs (lsp != { }) { inherit lsp; };

  extractExtensions =
    languages:
    lib.unique (
      lib.flatten (
        lib.mapAttrsToList (name: language: (languageMeta name).extensions or [ ]) (
          lib.filterAttrs (name: language: languageMeta name != null) languages
        )
      )
    );
in
{
  inherit
    extractExtensions
    resolveLanguages
    toZedSettings
    ;
}
