{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
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

  nativeBuildInputs = [ installAgentSkills ];

  # The repo ships the same skills in several places (one per agent); the
  # plugin copies are the complete ones.
  dontInstallAgentSkills = true;

  installPhase = ''
    runHook preInstall

    for skill in plugins/caveman/skills/*; do
      installSkill "$skill"
    done

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
