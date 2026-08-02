{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
}:

let
  pname = "via-source";
  version = "unstable-2026-07-21";

  src = fetchFromGitHub {
    owner = "the-via";
    repo = "app";
    rev = "077304fb36ce1fe6d1fdb3aeefd0924edb1a583a";
    hash = "sha256-hmtBoBNSlUWdB9d7fR0PuhRykzNjOmiTa35zG+88tTA=";
  };

  nodeModules = stdenv.mkDerivation {
    name = "${pname}-node-modules";
    inherit src;
    nativeBuildInputs = [ bun ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-CoQgjhe+4viIFSykKn0p9CFpzyAmWOMPzK8cUDy7qt8=";

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      export BUN_INSTALL_CACHE_DIR=$TMPDIR/.bun-cache
      bun install --frozen-lockfile
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r node_modules $out/node_modules
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [ bun ];

  buildPhase = ''
    runHook preBuild
    cp -r ${nodeModules}/node_modules .
    chmod -R u+w node_modules
    export HOME=$TMPDIR
    export PATH=$PWD/node_modules/.bin:$PATH

    pushd node_modules/via-keyboards
    bun run scripts/build-all.ts ../../public/definitions || true
    popd

    bunx vite build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/via
    cp -r dist/* $out/share/via/
    runHook postInstall
  '';

  meta = with lib; {
    description = "VIA keyboard configurator (built from source)";
    homepage = "https://usevia.app/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.all;
  };
}
