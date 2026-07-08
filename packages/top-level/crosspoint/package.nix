{
  lib,
  stdenv,
  fetchFromGitHub,
  platformio-core,
  python3,
  git,
  esptool,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "crosspoint";
  version = "1.4.1";

  __noChroot = true;

  src = fetchFromGitHub {
    owner = "crosspoint-reader";
    repo = "crosspoint-reader";
    rev = finalAttrs.version;
    hash = "sha256-h+Om7OUfp8JvmJdYTidXjStjLnySphLG14vFtawNhGA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    platformio-core
    python3
    git
    esptool
  ];

  buildPhase = ''
    runHook preBuild

    export HOME="$NIX_BUILD_TOP/home"
    mkdir -p "$HOME"

    pio run -e gh_release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"

    cp .pio/build/gh_release/firmware.bin "$out/"
    cp .pio/build/gh_release/bootloader.bin "$out/"
    cp .pio/build/gh_release/partitions.bin "$out/"

    cat > "$out/flash.sh" << 'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="''${1:-/dev/ttyACM0}"
    FIRMWARE_DIR="$(cd "$(dirname "$0")" && pwd)"

    echo "Flashing CrossPoint firmware to ESP32-C3 on $PORT..."
    echo "  firmware:   $FIRMWARE_DIR/firmware.bin"
    echo "  bootloader: $FIRMWARE_DIR/bootloader.bin"
    echo "  partitions: $FIRMWARE_DIR/partitions.bin"

    exec @esptool@ \
      --chip esp32c3 \
      --port "$PORT" \
      --baud 921600 \
      --before default_reset \
      --after hard_reset \
      write_flash \
        0x0000 "$FIRMWARE_DIR/bootloader.bin" \
        0x8000 "$FIRMWARE_DIR/partitions.bin" \
        0x10000 "$FIRMWARE_DIR/firmware.bin"
    EOF

    substituteInPlace "$out/flash.sh" \
      --subst-var-by esptool "${esptool}/bin/esptool"

    chmod +x "$out/flash.sh"

    runHook postInstall
  '';

  meta = {
    description = "CrossPoint Reader firmware for Xteink X4/X3 (ESP32-C3 e-reader)";
    homepage = "https://github.com/crosspoint-reader/crosspoint-reader";
    changelog = "https://github.com/crosspoint-reader/crosspoint-reader/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        name = "arunoruto";
      }
    ];
  };
})
