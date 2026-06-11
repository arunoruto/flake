# Helix editor integration for development language profiles
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Import the shared helix transformation library
  helixLib = import ../../lib/helix.nix {
    inherit lib;
    bash = lib.getExe pkgs.bashNonInteractive;
  };

  cfg = config.development;

  helixSelected = cfg.defaultEditor == "helix";
  helixEnabled = config.programs.helix.enable or false;

  # Get languages that are:
  # 1. Enabled
  # 2. Have configureHelix = true (or default true)
  languagesForHelix = lib.filterAttrs (
    name: lang: lang.enable && (lang.configureHelix or true)
  ) cfg.languages;
  resolvedLanguagesForHelix = helixLib.resolveLanguages cfg languagesForHelix;

  # Transform to helix format using shared library
  helixLanguages = helixLib.toHelixLanguages resolvedLanguagesForHelix;
  helixLspConfigs = helixLib.toHelixLspConfigs resolvedLanguagesForHelix;
in
{
  config =
    lib.mkIf
      (
        cfg.enable && cfg.autoConfigureEditors && helixSelected && helixEnabled && languagesForHelix != { }
      )
      {
        # Merge devenv-generated language config with existing helix config
        programs.helix.languages = lib.mkMerge [
          (lib.mkIf (helixLanguages != [ ]) { language = helixLanguages; })
          helixLspConfigs
        ];
      };
}
