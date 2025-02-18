{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "copilot-language-server";
  version = "1.269.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@github/copilot-language-server/-/copilot-language-server-${version}.tgz";
    hash = "";
  };

  npmDepsHash = "";

  # postPatch = ''
  #   ln -s ${./package-lock.json} package-lock.json
  # '';

  dontNpmBuild = true;

  # passthru.updateScript = ./update.sh;

  meta = {
    description = "Use GitHub Copilot with any editor or IDE via the Language Server Protocol";
    homepage = "https://github.com/features/copilot";
    license = lib.licenses.cc-by-40;
    mainProgram = "copilot-language-server";
    maintainers = with lib.maintainers; [ arunoruto ];
  };
}
