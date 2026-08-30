{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  openssl,
  SDL2,
  libGL,
  libxkbcommon,
  wayland,
  xorg,
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

  cargoHash = "sha256-zxDz5+1/oxVq6a8XndyF1WXKu+cXFWsh19aTQ5fXLQ0=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    openssl
    SDL2
  ];

  # winit/egui and SDL load their display backends via dlopen at runtime
  postFixup = ''
    wrapProgram $out/bin/partydeck \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          libxkbcommon
          wayland
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
        ]
      }
  '';

  # cargoBuildFlags = [
  #   "--package"
  #   "me3-cli"
  # ];
  #
  # cargoTestFlags = [
  #   "--package"
  #   "me3-cli"
  # ];

  meta = {
    homepage = "https://github.com/partydeck/partydeck";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/tag/v${finalAttrs.version}";
    description = "A split-screen game launcher for Linux/SteamOS";
    maintainers = with lib.maintainers; [ arunoruto ];
    license = lib.licenses.mit;
  };
})
