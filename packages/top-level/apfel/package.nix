{
  lib,
  stdenv,
  fetchurl,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apfel";
  version = "0.9.6";

  src = fetchurl {
    url = "https://github.com/Arthur-Ficial/apfel/releases/download/v${finalAttrs.version}/apfel-${finalAttrs.version}-arm64-macos.tar.gz";
    hash = "sha256-KVsB57hZM9cPbyophSWYni98jIxn3cBFYr58KSRooNo=";
  };

  sourceRoot = ".";

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp apfel $out/bin/
    chmod +x $out/bin/apfel

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Local Apple Intelligence LLM CLI and server";
    homepage = "https://github.com/Arthur-Ficial/apfel";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "apfel";
  };
})
