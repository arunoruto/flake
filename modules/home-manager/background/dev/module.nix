{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.dev;

  types = lib.types;

  commandType = types.either types.str types.path;

  lspServerSubmodule = types.submodule {
    options = {
      enable = lib.mkEnableOption "Enable this LSP server";

      kind = lib.mkOption {
        type = types.enum [ "language" "grammar" "tool" "ai" ];
        default = "language";
        description = "Classification of this LSP (used by adapters).";
      };

      exposeToOpencode = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Override for OpenCode export; usually leave enabled.";
      };

      tags = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Tags used to auto-attach this LSP to languages (e.g. ['python' 'markup']).";
      };

      package = lib.mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Package providing the LSP server binary (optional).";
      };

      command = lib.mkOption {
        type = commandType;
        description = "Executable name or absolute path for the LSP server.";
      };

      args = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Arguments passed to the LSP server.";
      };

      settings = lib.mkOption {
        type = types.attrs;
        default = { };
        description = "LSP initialization options/settings.";
      };

      environment = lib.mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Literal environment variables for this LSP server.";
      };

      environmentScript = lib.mkOption {
        type = types.lines;
        default = "";
        description = "Shell snippet prepended to the wrapper (for secrets, etc.).";
      };
    };
  };

  formatterSubmodule = types.submodule {
    options = {
      package = lib.mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Package providing the formatter binary (optional).";
      };

      command = lib.mkOption {
        type = commandType;
        description = "Executable name or absolute path for the formatter.";
      };

      args = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Arguments passed to the formatter.";
      };

      fileArg = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "$FILE";
        description = "Optional filename placeholder appended for file-based formatters.";
      };
    };
  };

  languageSubmodule = types.submodule {
    options = {
      enable = lib.mkEnableOption "Enable this language environment";

      tags = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Tags used to auto-attach LSP servers to this language (in addition to the implicit tag equal to the language name).";
      };

      autoAttachLspByTags = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether to auto-attach enabled LSP servers whose tags match this language.";
      };

      extensions = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "File extensions including dot (e.g. ['.py' '.pyi']).";
      };

      roots = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Project root marker files for editor LSP detection.";
      };

      autoFormat = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable auto-formatting (where supported).";
      };

      lspServers = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Names of LSP servers from programs.dev.lsp.servers (manually attached).";
      };

      formatter = lib.mkOption {
        type = types.nullOr formatterSubmodule;
        default = null;
      };

      packages = lib.mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Extra packages installed for this language (toolchain, etc.).";
      };

      helix = {
        fileTypes = lib.mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
          description = "Optional explicit Helix file-types (without dots).";
        };

        languageConfig = lib.mkOption {
          type = types.attrs;
          default = { };
          description = "Extra Helix language configuration merged in.";
        };
      };
    };
  };


  enabledLanguages = lib.filterAttrs (_: lang: lang.enable) cfg.languages;

    enabledLspServers = lib.filterAttrs (_: lsp: lsp.enable) cfg.lsp.servers;

    enabledOpencodeLspServers = lib.filterAttrs (
      _: lsp:
      lsp.enable && lsp.kind == "language" && (lsp.exposeToOpencode or true)
    ) cfg.lsp.servers;


  languageTags =
    lib.mapAttrs (
      name: lang:
      lib.unique ([ name ] ++ lang.tags)
    ) cfg.languages;

  lspMatchesLanguageTags =
    serverName: serverCfg: langName:
    let
      langTagSet = languageTags.${langName} or [ langName ];
    in
    lib.any (t: lib.elem t langTagSet) serverCfg.tags;

    autoLspForLanguage =
      langName:
      builtins.filter (
        serverName:
        let
          serverCfg = cfg.lsp.servers.${serverName};
        in
        lspMatchesLanguageTags serverName serverCfg langName
      ) (builtins.attrNames enabledLspServers);

    autoOpencodeLspForLanguage =
      langName:
      builtins.filter (
        serverName:
        let
          serverCfg = cfg.lsp.servers.${serverName};
        in
        lspMatchesLanguageTags serverName serverCfg langName
      ) (builtins.attrNames enabledOpencodeLspServers);


  effectiveLspServersForLanguage =
    langName: lang:
    lib.unique (
      lang.lspServers
      ++ lib.optionals lang.autoAttachLspByTags (
        builtins.filter (serverName: builtins.hasAttr serverName enabledLspServers) (autoLspForLanguage langName)
      )
    );

  referencedLspServers =
    lib.unique (
      lib.concatLists (
        lib.mapAttrsToList (langName: lang: effectiveLspServersForLanguage langName lang) enabledLanguages
      )
    );

  missingLspServers = builtins.filter (name: !(builtins.hasAttr name cfg.lsp.servers)) referencedLspServers;

  disabledReferencedLspServers = builtins.filter (
    name:
    (builtins.hasAttr name cfg.lsp.servers) && (!cfg.lsp.servers.${name}.enable)
  ) referencedLspServers;

  mkHelixCommand =
    lspName: lspCfg:
    let
      baseCommand = toString lspCfg.command;
    in
    if lspCfg.environment == { } && lspCfg.environmentScript == "" then
      baseCommand
    else
      lib.getExe (
        pkgs.writeShellApplication {
          name = "dev-lsp-${lspName}";
          runtimeInputs = lib.optionals (lspCfg.package != null) [ lspCfg.package ];
          text =
            (lib.optionalString (lspCfg.environmentScript != "") (lspCfg.environmentScript + "\n"))
            + (lib.concatStringsSep "\n" (
              lib.mapAttrsToList (k: v: "export ${k}=${lib.escapeShellArg v}") lspCfg.environment
            ))
            + "\nexec ${lib.escapeShellArg baseCommand} \"$@\"\n";
        }
      );

  mkHelixFileTypes = lang:
    if lang.helix.fileTypes != null then
      lang.helix.fileTypes
    else
      map (ext: lib.removePrefix "." ext) lang.extensions;

    opencodeLspExtensions =
      lib.foldl'
        (
          acc: langEntry:
          let
            langName = langEntry.name;
            lang = langEntry.value;

            effectiveOpencodeLspServersForLanguage =
              lib.unique (
                lang.lspServers
                ++ lib.optionals lang.autoAttachLspByTags (
                  builtins.filter (serverName: builtins.hasAttr serverName enabledOpencodeLspServers) (autoOpencodeLspForLanguage langName)
                )
              );
          in
          lib.foldl'
            (
              acc2: serverName:
              if builtins.hasAttr serverName enabledOpencodeLspServers then
                acc2
                // {
                  "${serverName}" = lib.unique ((acc2.${serverName} or [ ]) ++ lang.extensions);
                }
              else
                acc2
            )
            acc
            effectiveOpencodeLspServersForLanguage
        )
        { }
        (lib.mapAttrsToList (name: value: { inherit name value; }) enabledLanguages);


in
{
  options.programs.dev = {
    enable = lib.mkEnableOption "Unified development toolchain (LSP/formatters)";

     lsp = {
       servers = lib.mkOption {
         type = types.attrsOf lspServerSubmodule;
         default = { };
         description = "Registry of reusable LSP server definitions.";
       };
 
       ltex.ngram.enable = lib.mkEnableOption "Enable LTeX ngram downloads";
     };

     groups = {
       markup.enable = lib.mkEnableOption "Enable markup languages (json/yaml/toml/xml)";
     };
 
     languages = lib.mkOption {
       type = types.attrsOf languageSubmodule;
       default = { };
       description = "Language definitions referencing LSP servers + formatter.";
     };

    adapters = {
      helix.enable = lib.mkEnableOption "Generate Helix languages.toml";

      opencode.enable = lib.mkEnableOption "Generate OpenCode LSP/formatter config";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = missingLspServers == [ ];
        message = "programs.dev.languages references unknown LSP servers: ${lib.concatStringsSep ", " missingLspServers}";
      }
      {
        assertion = disabledReferencedLspServers == [ ];
        message = "programs.dev.languages references disabled LSP servers: ${lib.concatStringsSep ", " disabledReferencedLspServers}";
      }
    ];

    programs.dev.languages = lib.mkMerge [
      (lib.mkIf cfg.groups.markup.enable {
        json.enable = lib.mkDefault true;
        yaml.enable = lib.mkDefault true;
        toml.enable = lib.mkDefault true;
        xml.enable = lib.mkDefault true;
      })
    ];

    home.packages =
      lib.unique (
        builtins.filter lib.isDerivation (
          lib.concatLists (
            (lib.mapAttrsToList (_: v: lib.optionals (v.package != null) [ v.package ]) enabledLspServers)
            ++ (lib.mapAttrsToList (
              _: lang:
              (lib.optionals (lang.formatter != null && lang.formatter.package != null) [ lang.formatter.package ])
              ++ lang.packages
            ) enabledLanguages)
          )
        )
      );

    programs.helix = lib.mkIf cfg.adapters.helix.enable {
      languages = {
        language = lib.mapAttrsToList (
          name: lang:
          lang.helix.languageConfig
          // {
            inherit name;
            auto-format = lang.autoFormat;
            roots = lang.roots;
            file-types = mkHelixFileTypes lang;
            language-servers = effectiveLspServersForLanguage name lang;
          }
          // lib.optionalAttrs (lang.formatter != null) {
            formatter = {
              command = toString lang.formatter.command;
              args = lang.formatter.args;
            };
          }
        ) enabledLanguages;

        language-server = lib.mapAttrs (lspName: lspCfg: {
          command = mkHelixCommand lspName lspCfg;
          args = lspCfg.args;
          config = lspCfg.settings;
        }) enabledLspServers;
      };
    };

      programs.opencode = lib.mkIf cfg.adapters.opencode.enable {
        settings = {
          lsp = lib.mapAttrs (serverName: exts: {
            command = [ (toString enabledOpencodeLspServers.${serverName}.command) ] ++ enabledOpencodeLspServers.${serverName}.args;
            extensions = exts;
            env = enabledOpencodeLspServers.${serverName}.environment;
            initialization = enabledOpencodeLspServers.${serverName}.settings;
          }) opencodeLspExtensions;


        formatter =
          lib.foldl'
            lib.recursiveUpdate
            { }
            (lib.mapAttrsToList (
              langName: langCfg:
              if langCfg.formatter == null then
                { }
              else
                {
                  "${langName}-fmt" = {
                    command =
                      [ (toString langCfg.formatter.command) ]
                      ++ langCfg.formatter.args
                      ++ lib.optionals (langCfg.formatter.fileArg != null) [ langCfg.formatter.fileArg ];
                    extensions = langCfg.extensions;
                  };
                }
            ) enabledLanguages);
      };
    };
  };
}
