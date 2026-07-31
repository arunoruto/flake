# Zed adapter: render the resolved language set into Zed's user settings.
{
  config,
  lib,
  ...
}:

let
  consumers = import ../registry.nix { inherit lib; };
  zedLib = import ./transform.nix { inherit lib; };

  cfg = config.devix;

  # Languages enabled and exposed to Zed; within each, only the LSPs/formatters
  # enabled and exposed to Zed. Languages without Zed metadata are dropped by
  # the transform (capability).
  languagesForZed = consumers.languagesFor "zed" cfg.languages;
  resolved = consumers.resolveForConsumer "zed" cfg languagesForZed;

  zedSettings = zedLib.toZedSettings resolved;
  zedExtensions = zedLib.extractExtensions resolved;
  hasZedConfig = zedSettings != { } || zedExtensions != [ ];
in
{
  config = lib.mkIf (cfg.enable && cfg.consumers.zed.enable && hasZedConfig) {
    programs.zed-editor = {
      extensions = zedExtensions;
      userSettings = zedSettings;
    };
  };
}
