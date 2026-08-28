# Builder for Decky Loader plugins.
#
# A plugin is plain content: a directory holding `plugin.json`, `main.py` and a
# built `dist/`. Decky keeps each plugin's settings and data in sibling
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

        # Decky imports <plugin>/main.py unconditionally. Frontend-only plugins
        # ship no backend, and the store serves them with an empty stub; match
        # that so the loader can import them.
        [ -e "$out/${repo}/main.py" ] || touch "$out/${repo}/main.py"

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
