# Helix editor integration for devenv language profiles
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Import the shared helix transformation library
  helixLib = import ../../devenv/lib/helix.nix { inherit lib; };

  cfg = config.devenv;

  # Check if helix is enabled in home-manager
  helixEnabled = config.programs.helix.enable or false;

  # Get languages that are:
  # 1. Enabled
  # 2. Have configureHelix = true (or default true)
  languagesForHelix = lib.filterAttrs (
    name: lang: lang.enable && (lang.configureHelix or true)
  ) cfg.languages;

  # Transform to helix format using shared library
  helixLanguages = helixLib.toHelixLanguages languagesForHelix;
  helixLspConfigs = helixLib.toHelixLspConfigs languagesForHelix;
in
{
  config =
    lib.mkIf (cfg.enable && cfg.autoConfigureEditors && helixEnabled && languagesForHelix != { })
      {
        # Merge devenv-generated language config with existing helix config
        programs.helix.languages = lib.mkMerge [
          (lib.mkIf (helixLanguages != [ ]) { language = helixLanguages; })
          helixLspConfigs
        ];
      };
}
