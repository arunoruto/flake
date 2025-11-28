{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "context7";
  version = "1.0.30";

  # https://github.com/upstash/context7
  src = fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cNm/NROFHy+3cOozzvC1WUhGb7bwccvOIiMt30lAN3E=";
  };

  packageLockFile = ./package-lock.json;
  npmDepsHash = "sha256-dBWqrYI3TOShRRcSNuRhuzAfg8Xn/6PDGCkWTTmwEao=";

  postPatch = ''
    ln -s ${finalAttrs.packageLockFile} package-lock.json
  '';

  meta = {
    description = "MCP Server -- Up-to-date code documentation for LLMs and AI code editors ";
    homepage = "https://context7.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    mainProgram = "context7-mcp";
  };
})
