{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  patchelf,
  openssl,
  SDL2,
  libGL,
  libxkbcommon,
  wayland,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  gamescope,
  bubblewrap,
  kdePackages,
  fuse-overlayfs,
  zip,
  xdg-utils,
  umu-launcher,
  pkgsi686Linux,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;
  strictDeps = true;

  pname = "partydeck";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "partydeck";
    repo = "partydeck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aiiGEMqAo1QIOYcgoiBBmuxo9sCPSaiUdJRqAJLf0Oo=";
  };

  # Upstream's release tarball carries the Goldberg Steam Emu binaries
  # (res/goldberg) built from the gbe_fork submodule our source fetch
  # doesn't include; handlers with use_goldberg need them to let multiple
  # instances of a Steam game see each other.
  goldbergRelease = fetchurl {
    url = "https://github.com/partydeck/partydeck/releases/download/v${finalAttrs.version}/PartyDeck-${finalAttrs.version}.tar.gz";
    hash = "sha256-EmwMsG/Z8KtlugD209HqcTLP/s7QP2ucbl2tkIvmD/s=";
  };

  cargoHash = "sha256-zxDz5+1/oxVq6a8XndyF1WXKu+cXFWsh19aTQ5fXLQ0=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    copyDesktopItems
    patchelf
  ];

  buildInputs = [
    openssl
    SDL2
  ];

  # PATH_RES falls back to <exe dir>/res; point the /usr/share probe at our
  # own share dir instead so resources live in a normal place.
  postPatch = ''
    substituteInPlace src/paths.rs \
      --replace-fail "/usr/share/partydeck" "${placeholder "out"}/share/partydeck"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "partydeck";
      desktopName = "PartyDeck";
      comment = finalAttrs.meta.description;
      exec = "partydeck";
      icon = "partydeck";
      categories = [ "Game" ];
    })
  ];

  postInstall = ''
    mkdir -p $out/share/partydeck $out/bin/bin
    cp res/splitscreen_kwin.js res/splitscreen_kwin_vertical.js $out/share/partydeck/
    tar -xzf ${finalAttrs.goldbergRelease} -C $out/share/partydeck --strip-components=1 res/goldberg

    install -Dm644 res/icon.png $out/share/pixmaps/partydeck.png

    # umu-run and gamescope-kbm are looked up in /usr/bin, /usr/local/bin
    # and then <exe dir>/bin — never $PATH — so they have to sit next to the
    # binary. Upstream's gamescope-kbm is a fork with per-instance
    # keyboard/mouse routing; plain gamescope stands in until that fork is
    # packaged (controllers are unaffected).
    ln -s ${lib.getExe umu-launcher} $out/bin/bin/umu-run
    ln -s ${lib.getExe gamescope} $out/bin/bin/gamescope-kbm
  '';

  # The generate_interfaces tools ship prebuilt in the release tarball and
  # run on the host, so they need a store interpreter and rpath. The
  # steam_api libraries next to them are bind-mounted into the game's own
  # runtime and must stay untouched.
  postFixup = ''
    patchelf \
      --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
      --set-rpath ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]} \
      $out/share/partydeck/goldberg/generate_interfaces_x64
    patchelf \
      --set-interpreter ${pkgsi686Linux.glibc}/lib/ld-linux.so.2 \
      --set-rpath ${lib.makeLibraryPath [ pkgsi686Linux.stdenv.cc.cc.lib ]} \
      $out/share/partydeck/goldberg/generate_interfaces_x32

    # winit/egui and SDL dlopen their display backends; gamescope, bwrap and
    # kwin_wayland (--kwin mode) are spawned via PATH. Suffix so the system's
    # own builds (e.g. a host pinning a newer gamescope) win over ours.
    wrapProgram $out/bin/partydeck \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          libxkbcommon
          wayland
          libx11
          libxcursor
          libxi
          libxrandr
        ]
      } \
      --suffix PATH : ${
        lib.makeBinPath [
          gamescope
          bubblewrap
          kdePackages.kwin
          fuse-overlayfs
          zip
          xdg-utils
        ]
      }
  '';

  meta = {
    homepage = "https://github.com/partydeck/partydeck";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/tag/v${finalAttrs.version}";
    description = "A split-screen game launcher for Linux/SteamOS";
    maintainers = with lib.maintainers; [ arunoruto ];
    license = lib.licenses.mit;
  };
})
