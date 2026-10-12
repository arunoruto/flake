{
  lib,
  stdenv,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "astral-ai-plugins";
  version = "0-unstable-2026-02-27";

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "claude-code-plugins";
    rev = "f3ce88a7ba830f53afd6d944c1d0278ed318e142";
    hash = "sha256-yQ8R2R95QFXjYYbwAN0NdySObo8S2Cf/TecOQ9Ucr/A=";
  };

  # installAgentSkills picks up every SKILL.md folder on its own.
  nativeBuildInputs = [ installAgentSkills ];

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      # "--version-regex"
      # "${finalAttrs.pname}@(.*)"
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Atral-sh plugins for AI agents";
    homepage = "https://github.com/astral-sh/claude-code-plugins";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = lib.platforms.all;
  };
})
