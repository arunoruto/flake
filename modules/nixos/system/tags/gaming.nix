{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.lib.tags.hasTag "gaming") {
    programs.steam.enable = lib.mkDefault true;

    # Split-screen local coop; added to Steam as a non-Steam shortcut
    # (Gaming Mode wants `--kwin --fullscreen` in its launch options).
    environment.systemPackages = [ pkgs.partydeck ];
  };
}
