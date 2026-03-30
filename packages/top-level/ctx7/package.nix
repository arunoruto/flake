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
  pname = "ctx7";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    tag = "${finalAttrs.pname}@${finalAttrs.version}";
    hash = "sha256-dPNBcZte7S6sh72cx5XK/Zxbsfq+AhTszdtKPhEGDBM=";
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
    hash = "sha256-EjEdbPKXJbxaDBuAg/j+BSjI/W3HdsqbtDky0TPUB88=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm --filter ${finalAttrs.pname} build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm \
      --filter ${finalAttrs.pname} \
      --offline \
      --config.inject-workspace-packages=true \
      --config.shamefully-hoist=true \
      deploy $out/lib/ctx7

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/ctx7 \
      --add-flags "$out/lib/ctx7/dist/index.js"

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex '${finalAttrs.pname}@(.*)'" ];
  };

  meta = {
    description = "Context7 CLI - Manage AI coding skills and documentation context";
    homepage = "https://context7.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    mainProgram = "ctx7";
    platforms = with lib.platforms; linux ++ darwin;
  };
})
