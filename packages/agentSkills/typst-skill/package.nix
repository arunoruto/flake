{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "typst-skill";
  version = "0-unstable-2026-11-09";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "lucifer1004";
    repo = "claude-skill-typst";
    rev = "dcfe6144f6e5f6576fb55cf1a6b9970851a1aa78";
    hash = "sha256-BmIu/BJJXaWZ8vUepccs1K7wITMd2mnM3YjFyVCeGdI=";
  };

  # The hook finds skills/typst/SKILL.md, the repo's only skill.
  nativeBuildInputs = [ installAgentSkills ];

  # Upstream tags only old Typst snapshots (typst-0.14.2); main tracks the
  # current Typst release.
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Agent skill for writing Typst documents, templates and packages";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
