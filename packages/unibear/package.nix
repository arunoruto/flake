{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
  makeWrapper,
  deno,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "unibear";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "kamilmac";
    repo = "unibear";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ATySOd/oqmImLtSO/Am4LahEqbj91ns0ZZxRmpOUpD4=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ deno ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}
    cp -r $src/{src,LICENSE.md,README.md} $out/lib
    makeWrapper ${lib.getExe deno} $out/bin/unibear \
      --set DENO_NO_UPDATE_CHECK "1" \
      --add-flags "run -A $out/lib/src/main.ts"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
    # tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
  };

  meta = {
    description = "A lean TUI AI assistant: run your tools, stay in control, no magic tricks.";
    homepage = "https://github.com/kamilmac/unibear";
    license = lib.licenses.mit;
    mainProgram = finalAttrs.name;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with lib.maintainers; [ arunoruto ];
  };
})
