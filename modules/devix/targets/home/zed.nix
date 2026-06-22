# Zed editor integration for development language profiles
{
  config,
  lib,
  ...
}:

let
  consumersLib = import ../../lib/consumers.nix { inherit lib; };
  zedLib = import ../../lib/zed.nix { inherit lib; };

  cfg = config.development;

  # Languages enabled and exposed to Zed; within each, only the LSPs/formatters
  # enabled and exposed to Zed. Languages without Zed metadata are dropped by
  # the adapter (capability).
  languagesForZed = consumersLib.languagesFor "zed" cfg.languages;
  resolvedLanguagesForZed = consumersLib.resolveForConsumer "zed" cfg languagesForZed;

  zedSettings = zedLib.toZedSettings resolvedLanguagesForZed;
  zedExtensions = zedLib.extractExtensions resolvedLanguagesForZed;
  hasZedConfig = zedSettings != { } || zedExtensions != [ ];
in
{
  config = lib.mkMerge [
    {
      development.consumers.zed.enable = lib.mkDefault (
        cfg.autoConfigureEditors && (config.programs.zed-editor.enable or false)
      );
    }

    (lib.mkIf (cfg.enable && cfg.consumers.zed.enable && hasZedConfig) {
      programs.zed-editor = {
        extensions = zedExtensions;
        userSettings = zedSettings;
      };
    })
  ];
}
