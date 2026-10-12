{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nodejs,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ponytail";
  version = "4.13.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sf8WLd7PFXGRM7+LGaXDT/exA0YU9Ld8U5uZFBEqM/k=";
  };

  # The Claude Code hooks call a bare `node`, which a hook's non-interactive
  # shell may not have on PATH.
  postPatch = ''
    substituteInPlace hooks/claude-codex-hooks.json \
      --replace-fail 'node -e' '${lib.getExe nodejs} -e'
  '';

  dontConfigure = true;
  dontBuild = true;

  # Unlike the other agentSkills, this is loaded as a plugin rather than linked
  # through ai.skillPackages, so it keeps the repository layout instead of
  # share/skills/: the root is the plugin root for every agent (Claude Code reads
  # .claude-plugin/, OpenCode .opencode/plugins/, both share hooks/ and skills/).
  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Agent plugin that makes coding agents write the simplest code that works";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
