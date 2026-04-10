{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  # versionCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "caveman";
  version = "1.3.5";

  src = fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EAlKoqJuTMib+gcLscMtpS8Zzq/D/LmIRoG3g/XKThc=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r -L $src/plugins/caveman/skills $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  # nativeInstallCheckInputs = [ versionCheckHook ];
  # doInstallCheck = true;

  meta = {
    description = "Let AI agents speak like a caveman - why use many token when few token do trick ";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
