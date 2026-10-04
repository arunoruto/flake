# Builder for Decky Loader plugins.
#
# A plugin is plain content: a directory holding `plugin.json`, a built `dist/`
# and, if it has a backend, `main.py`. Decky keeps settings and data in sibling
# `settings/` and `data/` directories rather than inside the plugin itself, so
# nothing writes into these outputs at runtime and they are safe to keep in the
# store and symlink into place.
#
# Plugins publish a prebuilt tarball per release, so there is nothing to
# compile here.
{
  lib,
  stdenvNoCC,
  fetchzip,
}:

{
  pname,
  version,
  owner,
  # Release assets are named after the repository, which is also the directory
  # name Decky loads the plugin under and keys its settings by.
  repo ? pname,
  hash,
  meta ? { },
  ...
}@args:

stdenvNoCC.mkDerivation (
  lib.recursiveUpdate
    {
      inherit pname version;

      src = fetchzip {
        url = "https://github.com/${owner}/${repo}/releases/download/v${version}/${repo}.tar.gz";
        inherit hash;
      };

      __structuredAttrs = true;
      strictDeps = true;

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p "$out"
        cp -r . "$out/${repo}"

        # Note there is deliberately no `main.py` stub for frontend-only
        # plugins. Decky decides whether a plugin has a backend with
        # `passive = not path.isfile(main.py)`, so an empty file makes it try
        # `module.Plugin()` and fail with "module '_' has no attribute
        # 'Plugin'". A plugin without a backend must simply not have the file.

        runHook postInstall
      '';

      # The directory Decky must see, for the module to symlink into place.
      passthru.deckyPluginName = repo;

      meta = {
        homepage = "https://github.com/${owner}/${repo}";
        platforms = lib.platforms.linux;
      }
      // meta;
    }
    (
      removeAttrs args [
        "owner"
        "repo"
        "hash"
        "meta"
      ]
    )
)
