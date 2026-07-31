{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "autoresearch";
  version = "2.2.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "uditgoenka";
    repo = "autoresearch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WGVvYGmiC8X5iaJIL29IHfzNEeerQg0ucwlQIGiadbg=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    shopt -s dotglob
    cp -r ${finalAttrs.src}/* $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Autonomous goal-directed iteration skill for AI coding agents";
    homepage = "https://github.com/uditgoenka/autoresearch";
    changelog = "https://github.com/uditgoenka/autoresearch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = lib.platforms.all;
  };
})
