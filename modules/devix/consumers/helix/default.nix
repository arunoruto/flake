# Registry entry for the Helix consumer. See ../registry.nix.
{
  description = "Helix text editor";

  # Helix configures languages generically, so it can handle anything devix
  # defines and needs no per-language metadata.
  capability = "all";
  metaOptions = null;

  # Predicate on the Home Manager config: is this consumer's own program on?
  # Consulted only while `devix.autoEnable` holds.
  activeWhen = config: config.programs.helix.enable or false;

  # Command for EDITOR/VISUAL when picked as `devix.defaultEditor`.
  editorCommand = "hx";

  home = ./home.nix;

  # devenv adapter, or null when this consumer has no devenv story yet.
  devenv = ./devenv.nix;
}
