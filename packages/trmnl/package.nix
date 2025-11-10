{
  lib,
  stdenv,
  fetchFromGitHub,
  platformio,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "trmnl";
  version = "1.6.8";

  src = fetchFromGitHub {
    owner = "usetrmnl";
    repo = "trmnl-firmware";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OxzlQ7MM7iCP6B6YeucMtaUE3vzhngXA51S5BnzUUmc=";
  };

  nativeBuildInputs = [ platformio ];

  buildPhase = ''
    pio run --list-targets
  '';

  installPhase = ''
    mkdir -p $out

    cp -r * $out/
  '';

  meta = {
    description = "TRMNL e-ink device firmware";
    homepage = "usetrmnl.com";
    license = lib.licenses.gpl3;
    # platforms = lib.platforms.all;
  };
})
