# Registry entry for the OpenCode consumer. See ../registry.nix.
{
  description = "OpenCode AI coding agent";

  # OpenCode attaches servers to files by extension, so it can only configure a
  # language that tells it which extensions it owns.
  capability = "meta";

  metaOptions = lib: {
    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        ".py"
        ".pyi"
      ];
      description = "File extensions (leading dot) OpenCode should treat as this language.";
    };
  };

  activeWhen = config: config.programs.opencode.enable or false;

  # An AI harness, not an interactive editor: never a `defaultEditor` candidate.
  editorCommand = null;

  home = ./home.nix;

  # devenv adapter, or null when this consumer has no devenv story yet.
  devenv = null;
}
