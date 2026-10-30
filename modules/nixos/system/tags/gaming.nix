{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.lib.tags.hasTag "gaming") {
    programs.steam.enable = lib.mkDefault true;

    # Split-screen local coop; added to Steam as a non-Steam shortcut
    # (Gaming Mode wants `--kwin --fullscreen` in its launch options).
    # Off for now: it was only a trial, and nothing caches it, so every
    # 26.05 mass rebuild recompiled it locally.
    # environment.systemPackages = [ pkgs.partydeck ];
  };
}
