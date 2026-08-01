{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.lib.tags.hasTag "gaming") {
    programs.steam.enable = lib.mkDefault true;
  };
}
