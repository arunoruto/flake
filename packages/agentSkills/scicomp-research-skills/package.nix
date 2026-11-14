{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "scicomp-research-skills";
  version = "0-unstable-2026-10-14";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "a-attia";
    repo = "scicomp-research-skills";
    rev = "17bc2ea305606f74ce73ad01f859d119376848a0";
    hash = "sha256-TWx5/CyrseO6NHzJtsqZ8XIE9WRICLh6GHvCnOSqIOk=";
  };

  # The hook installs every skills/<name>/; ai.skillPackages links the wanted ones.
  nativeBuildInputs = [ installAgentSkills ];

  # Skills get split from the repo root; keep its licence and credits with them.
  postInstall = ''
    install -Dm444 -t $out/share/doc/${finalAttrs.pname} LICENSE ATTRIBUTION.md
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Agent skills for scientific-computing research papers and software";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
