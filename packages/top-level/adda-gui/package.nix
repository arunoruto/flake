{
  stdenv,
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  addDriverRunpath,
  makeWrapper,
  unzip,
  gradle_8,
  jdk11,

  libdrm,
  libgbm,
  libGL,
  libglvnd,
  xorg,

  adda,
}:
let
  gradle = gradle_8;
  jdk = jdk11;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "adda-gui";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "adda-team";
    repo = finalAttrs.pname;
    tag = "v${finalAttrs.version}";
    hash = "sha256-47ob8aiIajuKtsIeE6fuJyYWURLf1SI/9Xb41zfAfw8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    addDriverRunpath
    makeWrapper
    unzip
    gradle
  ];

  buildInputs =
    (with xorg; [
      libXcursor
      libXext
      libXrender
      libXrandr
      libXtst
      libXxf86vm
    ])
    ++ [
      jdk
      libdrm
      libGL
      libglvnd
      libgbm

      adda
    ];

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  gradleFlags = [ "-Dorg.gradle.java.home=${jdk}" ];
  gradleBuildTask = "installDist";

  patchPhase = ''
    runHook prePatch
    # Fix obsolete 'compile' keyword for dependencies
    sed -i 's/\bcompile\b/implementation/g' build.gradle
    # Add the application plugin to make 'installDist' available
    sed -i "/plugins {/a id 'application'" build.gradle
    # Define the main class for the application plugin
    sed -i "/^group =/a mainClassName = 'adda.Main'" build.gradle
    runHook postPatch
  '';

  preBuild = ''
    addAutoPatchelfSearchPath ${jdk}/lib/openjdk/lib/
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r build/install/adda-gui/* $out/
    cp -r ${finalAttrs.src}/help $out/

    mkdir -p $out/natives/linux-amd64
    find $out/lib -name "*-natives-linux-amd64.jar" -exec unzip -j -d $out/natives/linux-amd64 {} \*.so \;

    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/adda-gui \
      --set JAVA_HOME ${jdk} \
      --chdir "$out" \
      --prefix JAVA_OPTS " " "-Djava.library.path=${lib.makeLibraryPath [ libGL ]}"
  '';

  meta = with lib; {
    homepage = "https://github.com/adda-team/adda-gui";
    description = "Graphical user interface for ADDA";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ arunoruto ];
    mainProgram = "adda-gui";
  };
})
