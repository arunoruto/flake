# Helix adapter: render the resolved language set into programs.helix.languages.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  consumers = import ../registry.nix { inherit lib; };
  helixLib = import ./transform.nix {
    inherit lib;
    bash = lib.getExe pkgs.bashNonInteractive;
  };

  cfg = config.devix;

  # Languages enabled and exposed to Helix; within each, only the LSPs/formatters
  # that are enabled and exposed to Helix (consumers.helix.enable).
  languagesForHelix = consumers.languagesFor "helix" cfg.languages;
  resolved = consumers.resolveForConsumer "helix" cfg languagesForHelix;

  helixLanguages = helixLib.toHelixLanguages resolved;
  helixLspConfigs = helixLib.toHelixLspConfigs resolved;
in
{
  config = lib.mkIf (cfg.enable && cfg.consumers.helix.enable && languagesForHelix != { }) {
    # Merge devix-generated language config with existing helix config.
    programs.helix.languages = lib.mkMerge [
      (lib.mkIf (helixLanguages != [ ]) { language = helixLanguages; })
      helixLspConfigs
    ];
  };
}
