{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
  # Only run on an explicit /anatomy, never chosen by the agent on its own.
  manualOnly ? false,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "anatomy";
  version = "0-unstable-2026-10-11";

  src = fetchFromGitHub {
    owner = "wheresryan22";
    repo = "anatomy";
    rev = "240a9bf7c50cc6226148762a1017466fcbc08523";
    hash = "sha256-TmxmVsoJeBn/S7we8pwZ3ebEhcXtMy1JfIPI6aY4Srs=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  dontConfigure = true;
  dontBuild = true;

  # The skill assumes a writable checkout, Node on PATH and Chrome at FHS
  # paths; tell the agent how it differs here.
  postPatch = ''
    cat ${./nix-notes.md} >> SKILL.md
  ''
  + lib.optionalString manualOnly ''
    if grep -qE '^(disable-model-invocation|metadata):' SKILL.md; then
      echo "SKILL.md frontmatter already sets invocation keys; update the patch" >&2
      exit 1
    fi
    awk '/^---$/ && ++n == 2 {
      print "disable-model-invocation: true"
      print "metadata:"
      print "  opencode/slash: \"true\""
      print "  opencode/autoinvoke: \"false\""
    } { print }' SKILL.md > SKILL.md.new
    mv SKILL.md.new SKILL.md
  '';

  nativeBuildInputs = [ installAgentSkills ];

  # SKILL.md sits at the repo root, next to repo-only files (CI, evals,
  # contributor docs); stage just the skill's own files instead.
  dontInstallAgentSkills = true;

  installPhase = ''
    runHook preInstall

    mkdir -p staging/anatomy
    cp -r SKILL.md LICENSE kit references scripts examples staging/anatomy/
    installSkill staging/anatomy

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Agent skill for detailed, interactive isometric SVG figures of technical ideas";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
