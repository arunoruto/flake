{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "copilot-language-server";
  version = "1.272.0";
  # version = "1.269.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@github/copilot-language-server/-/copilot-language-server-${version}.tgz";
    hash = "sha256-LzNwf9mEppk8AhwWM6U88thugoceOjUk9FBpPHi4O2M=";
  };

  npmDepsHash = "sha256-LiIVfW1PIEgx+tnsEgungxjYpWOCTaiB7qdIdCT8nmI=";

  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';

  postInstall = ''
    ls -la $out
    ln -s $out/lib/node_modules/@github/copilot-language-server/dist $out/lib/node_modules/@github/dist
  '';

  dontNpmBuild = true;

  # passthru.updateScript = ./update.sh;

  meta = {
    description = "Use GitHub Copilot with any editor or IDE via the Language Server Protocol";
    homepage = "https://github.com/features/copilot";
    license = lib.licenses.cc-by-40;
    mainProgram = "copilot-language-server";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ arunoruto ];
  };
}
