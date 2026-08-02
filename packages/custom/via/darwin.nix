{
  stdenvNoCC,
  undmg,
  lib,
  makeBinaryWrapper,
}:

{
  pname,
  version,
  src,
  meta,
  __structuredAttrs ? true,
  strictDeps ? true,
}:

stdenvNoCC.mkDerivation {
  inherit
    pname
    version
    src
    meta
    __structuredAttrs
    strictDeps
    ;

  nativeBuildInputs = [
    undmg
    makeBinaryWrapper
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    cp -a Via.app $out/Applications

    makeBinaryWrapper $out/Applications/Via.app/Contents/MacOS/Via $out/bin/via

    runHook postInstall
  '';
}
