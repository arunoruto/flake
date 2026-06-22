# Helix editor integration for development language profiles
{
  config,
  lib,
  pkgs,
  ...
}:

let
  consumersLib = import ../../lib/consumers.nix { inherit lib; };
  # Import the shared helix transformation library
  helixLib = import ../../lib/helix.nix {
    inherit lib;
    bash = lib.getExe pkgs.bashNonInteractive;
  };

  cfg = config.development;

  # Languages enabled and exposed to Helix; within each, only the LSPs/formatters
  # that are enabled and exposed to Helix (consumers.helix.enable).
  languagesForHelix = consumersLib.languagesFor "helix" cfg.languages;
  resolvedLanguagesForHelix = consumersLib.resolveForConsumer "helix" cfg languagesForHelix;

  # Transform to helix format using shared library
  helixLanguages = helixLib.toHelixLanguages resolvedLanguagesForHelix;
  helixLspConfigs = helixLib.toHelixLspConfigs resolvedLanguagesForHelix;
in
{
  config = lib.mkMerge [
    # The Helix consumer is active whenever the Helix program is enabled (can be
    # forced on/off via development.consumers.helix.enable).
    {
      development.consumers.helix.enable = lib.mkDefault (config.programs.helix.enable or false);
    }

    (lib.mkIf
      (cfg.enable && cfg.autoConfigureEditors && cfg.consumers.helix.enable && languagesForHelix != { })
      {
        # Merge devix-generated language config with existing helix config
        programs.helix.languages = lib.mkMerge [
          (lib.mkIf (helixLanguages != [ ]) { language = helixLanguages; })
          helixLspConfigs
        ];
      }
    )
  ];
}
