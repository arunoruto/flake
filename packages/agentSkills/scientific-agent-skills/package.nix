{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "scientific-agent-skills";
  version = "2.72.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "K-Dense-AI";
    repo = "scientific-agent-skills";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W6gYxezjV8sUJq7Bnh2Yx369f0oO6pVmtCS7HvIPGcg=";
  };

  # The hook installs every skills/<name>/; ai.skillPackages links the wanted ones.
  nativeBuildInputs = [ installAgentSkills ];

  # Skills get split from the repo root; keep its licence with them.
  postInstall = ''
    install -Dm444 -t $out/share/doc/${finalAttrs.pname} LICENSE.md
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Agent skills for scientific research, writing, figures and statistics";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
