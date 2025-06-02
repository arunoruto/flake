{
  lib,
  stdenvNoCC,
  fetchurl,
  nix-update-script,
  # versionCheckHook,

  testers,
}:

let
  os-arch =
    {
      aarch64-darwin = "unibear-darwin_aarch64-apple-darwin";
      aarch64-linux = "unibear-linux_aarch64-unknown-linux-gnu";
      x86_64-darwin = "unibear-darwin_x86_64-apple-darwin";
      x86_64-linux = "unibear-linux_x86_64-unknown-linux-gnu";
    }
    ."${stdenvNoCC.hostPlatform.system}"
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "unibear";
  version = "0.4.2";

  src = fetchurl {
    url = "https://github.com/kamilmac/unibear/releases/download/v${finalAttrs.version}/${os-arch}";
    hash = "sha256-4ahYZvdrRBIeI9+xV6SL+03JQALiq83hGmq5ZEZnIPA=";
    # inherit (finalAttrs) pname;
    # name = finalAttrs.pname;
    # stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install "$src" -Dm755 "$out"/bin/${finalAttrs.pname}

    runHook postInstall
  '';

  dontUnpack = true;

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
  };

  # nativeInstallCheckInputs = [ versionCheckHook ];
  # versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.pname}";
  # versionCheckProgramArg = [ "--version" ];
  # doInstallCheck = true;

  meta = {
    description = "A lean TUI AI assistant: run your tools, stay in control, no magic tricks.";
    homepage = "https://github.com/kamilmac/unibear";
    licence = lib.licenses.mit;
    mainProgram = finalAttrs.pname;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "arm64-apple-darwin"
    ];
    maintainers = with lib.maintainers; [ arunoruto ];
  };
})
