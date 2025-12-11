{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ai-commit";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "arunoruto";
    repo = "ai-commit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NV1pc9adOqVyUf0NUgn51TLfeaBs8NhV88SO5XVXsOM=";
  };

  installPhase = ''
    mkdir -p $out/bin
    install -m755 ai-commit.sh $out/bin/ai-commit
    install -m755 ai-tag.sh $out/bin/ai-tag
    cp common.sh $out/bin/common.sh
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--subpackage"
      "webui"
    ];
  };

  meta = {
    description = " Generate commit messages via AI ";
    homepage = "https://github.com/arunoruto/ai-commit";
    mainProgram = "ai-commit";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
