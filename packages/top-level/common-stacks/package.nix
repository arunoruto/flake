{
  lib,
  stdenv,
  nixosTests,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  nodejs,
  npmHooks,
  bun,
  # pdfium-binaries,
  # openssl,
  # dbus,
  # glib,
  # gtk3,
  webkitgtk_4_1,
  # cacert,
  pkg-config,
  wrapGAppsHook3,
  makeWrapper,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "common-stacks";
  version = "0.1.10";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "SoFriendly";
    repo = "common-stacks";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sAdNu7dTKmk0C9UjmziAsSOAohc4z9HHW2GtFVQWCSs=";
  };

  nodeModules = stdenv.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) src version;

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      bun install \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r node_modules $out/node_modules

      runHook postInstall
    '';

    outputHash = "sha256-zLNJ2WJbBPtkJr+l9f+MuZyrcple0RtGB/863lfIR3g=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  cargoHash = "sha256-I/vad3qjqArMjVhee5EgJkdz+V3vojhYfDBFJ3PZ1Bk=";
  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  tauriBuildFlags = [
    "--no-sign"
  ];

  # cargoBuildFlags = [
  #   "--package"
  #   "stump_server"
  #   "--bin"
  #   "stump_server"
  # ];

  # env.GIT_REV = "v${finalAttrs.version}";

  nativeBuildInputs = [
    cargo-tauri.hook
    bun
    nodejs
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook3 ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ makeWrapper ];

  # nativeCheckInputs = [
  #   cacert
  # ];

  buildInputs = [
    # openssl
    # dbus
    # glib
    # gtk3
    webkitgtk_4_1
  ];

  postPatch = ''
    cp -r ${finalAttrs.nodeModules}/node_modules .
    chmod -R +w node_modules
    patchShebangs --build node_modules
  '';

  # postInstall = ''
  #   wrapProgram $out/bin/stump_server \
  #     --set-default STUMP_CONFIG_DIR /var/lib/stump/config \
  #     --set-default STUMP_CLIENT_DIR ${finalAttrs.frontend} \
  #     --set-default STUMP_PORT 10001 \
  #     --set-default STUMP_PROFILE release \
  #     --set-default PDFIUM_PATH ${pdfium-binaries}/lib/libpdfium.so \
  #     --set-default API_VERSION v1
  # '';

  passthru = {
    # tests = nixosTests.stump;
    updateScript = nix-update-script {
      # extraArgs = [
      #   "--subpackage"
      #   "frontend"
      # ];
    };
  };

  meta = {
    homepage = "https://commonstacks.com/";
    description = " Cross-Platform Local OPDS Browser ";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    # mainProgram = "stump_server";
  };
})
