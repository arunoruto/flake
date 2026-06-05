{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  webkitgtk_4_1,
  gtk3,
  glib,
  bun,
  nodejs,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "openchamber";
  version = "1.11.7";

  src = fetchFromGitHub {
    owner = "openchamber";
    repo = "openchamber";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yEgZXDjN9BjUDh5grpsXbyI4Ttjqtoc5DjxG84UFD8g=";
  };

  cargoRoot = "packages/desktop/src-tauri";
  buildAndTestSubdir = "packages/desktop/src-tauri";

  cargoHash = "sha256-kVsLCPGKFpuZ10I5Q8260Hw6ZqEjnT5ufR7/JR5eGiY=";

  nativeBuildInputs = [
    pkg-config
    bun
    nodejs
  ];

  buildInputs = [
    openssl
    webkitgtk_4_1
    gtk3
    glib
  ];

  passthru = {
    bunDeps = stdenvNoCC.mkDerivation (finalDepsAttrs: {
      name = "${finalAttrs.pname}-bun-deps-${finalAttrs.version}";
      src = finalAttrs.src;

      nativeBuildInputs = [ bun ];

      dontFixup = true;

      buildPhase = ''
        export BUN_INSTALL_CACHE_DIR=$TMPDIR/bun-cache
        bun install --no-save --ignore-scripts
      '';

      installPhase = ''
        mkdir -p $out
        # 1. NEW: Find ALL node_modules folders (root and nested) and copy them 
        # to $out using --parents to perfectly preserve the monorepo folder structure!
        find . -name node_modules -type d -prune -exec cp -a --parents {} $out/ \;
      '';

      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-MU/FNUCcj7YzPXmnjsf/nQ52WmN5zFOYnxev78PY/XY=";
    });
  };

  preBuild = ''
    # 3. Inject ALL pre-fetched node_modules into their respective directories
    cp -a ${finalAttrs.passthru.bunDeps}/* .
    chmod -R +w .

    export PATH=$PWD/node_modules/.bin:$PATH

    # 4. Recursively fix /usr/bin/env shebangs in EVERY node_modules folder 
    patchShebangs .

    # Force the sidecar build script to use our Nix Bun binary
    # (This bypasses a subshell probe in build-sidecar.mjs that fails in Nix)
    export BUN=${bun}/bin/bun

    # Build the frontend UI
    bun run build

    # 5. CRITICAL FIX: Build the Tauri sidecar explicitly before Cargo runs!
    # Since we disable Tauri's beforeBuildCommand, we must compile the bun 
    # backend into a standalone binary ourselves so Tauri's build.rs can bundle it.
    (cd packages/desktop && bun run build:sidecar)

    # Prevent Tauri from trying to rebuild the frontend or sidecar itself
    sed -i 's/"beforeBuildCommand":.*"/"beforeBuildCommand": ""/' packages/desktop/src-tauri/tauri.conf.json
  '';

  checkFlags =
    let
      skippedTests = [
        "tests::probe_returns_wrong_service_for_generic_http_200_health"
        "tests::wait_for_local_opencode_ready_returns_last_probe_when_server_never_becomes_ready"
      ];
    in
    map (test: "--skip=${test}") skippedTests;

  # checkFlags = [
  #   # These tests mock HTTP health probes and fail inside the Nix network sandbox
  #   "--skip=tests::probe_returns_wrong_service_for_generic_http_200_health"
  #   "--skip=tests::wait_for_local_opencode_ready_returns_last_probe_when_server_never_becomes_ready"
  # ];

  meta = with lib; {
    description = "Desktop and web interface for OpenCode AI agent";
    homepage = "https://github.com/openchamber/openchamber";
    license = licenses.mit;
    maintainers = with maintainers; [ arunoruto ];
    mainProgram = "openchamber";
    platforms = platforms.linux;
  };
})
