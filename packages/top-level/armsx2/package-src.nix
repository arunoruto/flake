{
  stdenv,
  lib,
  fetchFromGitHub,

  cmake,
  pkg-config,

  # Core dependencies
  libpng,
  libjpeg,
  zlib,
  zstd,
  lz4,
  libwebp,
  sdl3,
  freetype,
  plutovg,
  plutosvg,
  curl,
  libpcap,
  shaderc,

  # Qt 6 stuff
  qt6,

  # macOS specific stuff (remove `darwin` from the arguments)
  vulkan-headers,
  vulkan-loader,
  moltenvk,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "armsx2";
  version = "2.6.9";

  src = fetchFromGitHub {
    owner = "armsx2";
    repo = "armsx2";
    tag = finalAttrs.version;
    hash = "sha256-H0bEmMVnQRziipKzUWB5+vGkNzdDWQdxsbqv7OiiK0c=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook # Required so the final app bundle can find Qt plugins
  ];

  buildInputs = [
    libpng
    libjpeg
    zlib
    zstd
    lz4
    libwebp
    curl
    libpcap
    sdl3
    freetype
    plutovg
    plutosvg
    shaderc
    qt6.qtbase
    qt6.qttools
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Explicit macOS frameworks are gone. The SDKROOT provides them automatically.
    # Just include the Vulkan/MoltenVK translation layers.
    vulkan-headers
    vulkan-loader
    moltenvk
  ];

  # preBuild = ''
  #   makeFlagsArray+=(${flags})
  #   cd src/
  # '';

  # installPhase = ''
  #   runHook preInstall

  #   install "${target}/${binaryName}" -Dm755 -t "$out"/bin

  #   runHook postInstall
  # '';

  meta = {
    homepage = "https://armsx2.net/";
    description = "Playstation 2 Emulator for ARM64 Platforms";
    license = lib.licenses.gpl3;
    platforms = [ "aarch64-darwin" ];
    maintainers = with lib.maintainers; [ arunoruto ];
    mainProgram = "armsx2";
  };
})
