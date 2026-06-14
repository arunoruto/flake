# Zed editor integration for development language profiles
{
  config,
  lib,
  ...
}:

let
  zedLib = import ../../lib/zed.nix { inherit lib; };

  cfg = config.development;
  zedEnabled = config.programs.zed-editor.enable or false;

  languagesForZed = lib.filterAttrs (_: lang: lang.enable) cfg.languages;
  resolvedLanguagesForZed = zedLib.resolveLanguages cfg languagesForZed;

  zedSettings = zedLib.toZedSettings resolvedLanguagesForZed;
  zedExtensions = zedLib.extractExtensions resolvedLanguagesForZed;
in
{
  config = lib.mkIf (cfg.enable && cfg.autoConfigureEditors && zedEnabled && languagesForZed != { }) {
    programs.zed-editor = {
      extensions = zedExtensions;
      userSettings = zedSettings;
    };
  };
}
