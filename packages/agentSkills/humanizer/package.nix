{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "humanizer";
  version = "4.0.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "blader";
    repo = "humanizer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-brVRFNvqMttKMZdlxrgmU01VOlxbyU6zQ8zd6qT4eZ8=";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ installAgentSkills ];

  # SKILL.md sits at the repo root next to plugin manifests, CI and contributor
  # docs; stage just the skill itself.
  dontInstallAgentSkills = true;

  installPhase = ''
    runHook preInstall

    mkdir -p staging/humanizer
    cp SKILL.md LICENSE staging/humanizer/
    installSkill staging/humanizer

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Agent skill that rewrites AI-sounding text so it reads like a person wrote it";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
