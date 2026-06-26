{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  python3,
  unzip,
  mupdf,
  freetype,
  harfbuzz,
  openjpeg,
  jbig2dec,
  gumbo,
  zlib,
  fontconfig,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bookokrat";
  version = "0.3.12";

  src = fetchFromGitHub {
    owner = "bugzmanov";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-OefSWMUtZdkXnebP2InvzmMCiSpLtN6ewsnzotQiOxY=";
  };

  cargoHash = "sha256-OIZElPcEJVC4clgWgBApnEKYNvYrBGhWhFUebf3tcnM=";

  nativeBuildInputs = [
    pkg-config
    python3
    rustPlatform.bindgenHook
    unzip
  ];

  buildInputs = [
    mupdf
    freetype
    harfbuzz
    openjpeg
    jbig2dec
    gumbo
    zlib
    fontconfig
  ];

  meta = with lib; {
    description = "Terminal EPUB/PDF/DJVU reader with vim-style keybindings";
    homepage = "https://github.com/bugzmanov/bookokrat";
    license = licenses.agpl3Plus;
    mainProgram = "bookokrat";
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ arunoruto ];
  };
})
