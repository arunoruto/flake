# Registry entry for the Zed consumer. See ../registry.nix.
{
  description = "Zed editor";

  # Zed addresses languages by its own display name and curates its own server
  # list, so it can only configure languages that say how (`consumerMeta.zed`).
  capability = "meta";

  metaOptions = lib: {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Zed's display name for the language; the key under `languages` in its settings.";
    };

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Zed extensions to install for this language.";
    };

    languageServers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        The curated, ordered `language_servers` list Zed should use. May contain
        the literal "..." token (Zed's "then the defaults" marker) and may
        deliberately omit devix servers that Zed handles better with its own
        built-ins. Only the servers named here get a `lsp.<id>.binary` override.
      '';
    };
  };

  activeWhen = config: config.programs.zed-editor.enable or false;

  # `--wait` so Zed behaves as a blocking EDITOR (git commit, …).
  editorCommand = "zed --wait";

  home = ./home.nix;

  # devenv adapter, or null when this consumer has no devenv story yet.
  devenv = null;
}
