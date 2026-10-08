{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  rustPlatform,
  love,
  SDL2,
  curl,
  p7zip,
  zip,
  strip-nondeterminism,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
}:

let
  inherit (stdenvNoCC.hostPlatform) isLinux extensions;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gen1recomp";
  version = "0.3.63";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "bryanthaboi";
    repo = "gen1recomp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+ATSBdQUleA1FCpvNTLd90ARvcGUKzMMUhUlnmj7DXo=";
  };

  # The tree carries a dev placeholder; upstream's CI stamps the release
  # version into the packed archive (scripts/pack_love.sh). The updater and
  # mod/link compatibility checks read it.
  postPatch = ''
    substituteInPlace src/core/Version.lua \
      --replace-fail 'engine = "0.0.0-dev"' 'engine = "${finalAttrs.version}"'
  '';

  nativeBuildInputs = [
    makeWrapper
    strip-nondeterminism
    zip
  ]
  ++ lib.optionals isLinux [ copyDesktopItems ];

  # Same file set as scripts/pack_love.sh, which is what release .love files
  # are made of. Generated ROM data never ships; it is built on first launch.
  buildPhase = ''
    runHook preBuild

    zip -q -9 -r -X gen1recomp.love \
      main.lua conf.lua src data assets tools/save-editor \
      tools/rom_manifest*.json mobile/ios/app-repo.json \
      -x '*.DS_Store' 'data/generated/*' 'assets/generated/*'
    strip-nondeterminism --type zip gen1recomp.love

    runHook postBuild
  '';

  desktopItems = lib.optionals isLinux [
    (makeDesktopItem {
      name = "gen1recomp";
      exec = "gen1recomp";
      icon = "gen1recomp";
      desktopName = "gen1recomp";
      comment = "LÖVE2D recreation of the Game Boy and GBA Pokémon games";
      categories = [ "Game" ];
      startupWMClass = "love";
    })
  ];

  # The ShaderFX bridge is looked up next to the .love. Host tools the game
  # shells out to: curl (updates, mods, online play) and 7z (archived ROMs);
  # PATH is suffixed so the session's own zenity/kdialog picker is used.
  # SDL2 is dlopened by its bare name for sensors and frame pacing, which
  # needs the unversioned library on the search path.
  installPhase = ''
    runHook preInstall

    install -Dm444 gen1recomp.love -t $out/share/gen1recomp
    ln -s ${finalAttrs.passthru.shaderfx-bridge}/lib/liblibrashader_bridge${extensions.sharedLibrary} \
      $out/share/gen1recomp/
    install -Dm444 assets/logo/gen1recomp_cover.png \
      $out/share/icons/hicolor/1024x1024/apps/gen1recomp.png

    makeWrapper ${lib.getExe love} $out/bin/gen1recomp \
      --add-flags $out/share/gen1recomp/gen1recomp.love \
      --suffix PATH : ${
        lib.makeBinPath [
          curl
          p7zip
        ]
      } \
      --prefix ${
        if isLinux then "LD_LIBRARY_PATH" else "DYLD_LIBRARY_PATH"
      } : ${lib.makeLibraryPath [ SDL2 ]}

    runHook postInstall
  '';

  passthru = {
    # Translates RetroArch shader presets for the in-game SHADER FX menu.
    shaderfx-bridge = rustPlatform.buildRustPackage {
      pname = "gen1recomp-shaderfx-bridge";
      inherit (finalAttrs) version src;
      sourceRoot = "${finalAttrs.src.name}/tools/shaderfx-bridge";
      cargoHash = "sha256-UDNx5rI9zPqYx9ytaP9MmzvDc0ex7x/XM/mBBbc433Y=";

      # Only the cdylib is loaded; the crate's `spike` CLI and the staticlib
      # are developer leftovers.
      cargoBuildFlags = [ "--lib" ];
      postInstall = ''
        rm -rf $out/bin $out/lib/*.a
      '';

      __structuredAttrs = true;
      strictDeps = true;
    };
    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "shaderfx-bridge"
      ];
    };
  };

  meta = {
    description = "Native LÖVE2D recreation of the Game Boy and GBA Pokémon games, decoded from your own ROM";
    homepage = "https://github.com/bryanthaboi/gen1recomp";
    changelog = "https://github.com/bryanthaboi/gen1recomp/releases/tag/${finalAttrs.src.tag}";
    # GPLv3 with attribution terms for the engine. The launcher is
    # proprietary and may only be redistributed inside official releases:
    # building it locally is fine, publishing the output (Cachix) is not.
    license = with lib.licenses; [
      gpl3Only
      unfree
    ];
    mainProgram = "gen1recomp";
    inherit (love.meta) platforms;
  };
})
