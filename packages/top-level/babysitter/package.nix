{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  versionCheckHook,

  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "babysitter";
  version = "0.0.187";

  src = fetchFromGitHub {
    owner = "a5c-ai";
    repo = "babysitter";
    tag = "v${finalAttrs.version}";
    hash = "";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "";
  };

  # buildPhase = ''
  #   runHook preBuild

  #   pnpm --filter ${finalAttrs.pname} build

  #   runHook postBuild
  # '';

  # installPhase = ''
  #   runHook preInstall

  #   pnpm \
  #     --filter ${finalAttrs.pname} \
  #     --offline \
  #     --config.inject-workspace-packages=true \
  #     --config.shamefully-hoist=true \
  #     deploy $out/lib/ctx7

  #   mkdir -p $out/bin
  #   makeWrapper ${nodejs}/bin/node $out/bin/ctx7 \
  #     --add-flags "$out/lib/ctx7/dist/index.js"

  #   runHook postInstall
  # '';

  # nativeInstallCheckInputs = [ versionCheckHook ];
  # doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Babysitter - Enforce obedience to agentic workforces";
    homepage = "Chttps://www.a5c.ai/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    mainProgram = "babysitter";
    platforms = with lib.platforms; linux;
  };
})
