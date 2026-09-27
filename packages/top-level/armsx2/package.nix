{
  lib,
  stdenvNoCC,
  fetchzip,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "armsx2-mac-bin";
  version = "2.6.2";

  src = fetchzip {
    url = "https://github.com/armsx2/armsx2/releases/download/${finalAttrs.version}/armsx2-macos-arm64-sha.112cd677b4.tar.xz";
    hash = "sha256-yXnSfMYKCP10XsHUdLkyVcyMAjLoL1bq56LHipOZvHg=";
    stripRoot = false;
  };

  __structuredAttrs = true;
  strictDeps = true;

  # Required to use the makeWrapper command
  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    cp -R *.app $out/Applications/

    APP_DIR=$(ls -d *.app)

    # Grab the exact path to the executable inside the MacOS folder
    EXECUTABLE=$(find "$out/Applications/$APP_DIR/Contents/MacOS/" -type f -executable | head -n 1)

    # makeWrapper creates a bash script in $out/bin that explicitly runs the 
    # executable from its true path, preserving the application's folder structure.
    makeWrapper "$EXECUTABLE" "$out/bin/armsx2"

    runHook postInstall
  '';

  meta = with lib; {
    description = "ARMSX2 PlayStation 2 Emulator (Prebuilt Binary)";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "armsx2";
  };
})
