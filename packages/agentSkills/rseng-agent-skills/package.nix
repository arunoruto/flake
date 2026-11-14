{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  installAgentSkills,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rseng-agent-skills";
  version = "0.2.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "fdiblen";
    repo = "rseng-agent-skills";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DAsQIDkzEul9FKhXbn4t0zh/YlAHq/v0v8KIo3IHKHE=";
  };

  # The hook installs every skills/<name>/; ai.skillPackages links the wanted ones.
  nativeBuildInputs = [ installAgentSkills ];

  # Skill text is CC-BY-4.0 with credits in ATTRIBUTION.md; keep both with the skills.
  postInstall = ''
    install -Dm444 -t $out/share/doc/${finalAttrs.pname} LICENSE LICENSE-content ATTRIBUTION.md NOTICE
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Research software engineering skills for coding agents";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    license = with lib.licenses; [
      mit
      cc-by-40
    ];
    platforms = lib.platforms.all;
  };
})
