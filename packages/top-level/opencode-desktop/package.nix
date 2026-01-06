{
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeBinaryWrapper,
  webkitgtk_4_1,
  gtk3,
  cairo,
  gdk-pixbuf,
  glib,
  dbus,
  openssl,
  librsvg,
  libappindicator-gtk3,
  zlib,
  gst_all_1,
  opencode,
}:

stdenv.mkDerivation rec {
  pname = "opencode-desktop";
  version = "1.1.2";

  src = builtins.fetchurl {
    url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-desktop-linux-amd64.deb";
    hash = "sha256-Xgs66mrS2goZQB2HDqFlu8o13d3GW+OEAl8GIuEOp9s=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    makeBinaryWrapper
  ];

  buildInputs = [
    gtk3
    cairo
    gdk-pixbuf
    glib
    dbus
    openssl
    librsvg
    webkitgtk_4_1
    libappindicator-gtk3
    zlib
    # GStreamer dependencies required by WebKitGTK
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base # Contains 'appsink'
    gst_all_1.gst-plugins-good # Contains 'autoaudiosink'
    gst_all_1.gst-plugins-bad # Often needed for WebKit extensions
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    dpkg -x $src $out

    # 1. Clean up file structure
    if [ -d "$out/usr" ]; then
      cp -rf $out/usr/* $out/
      rm -rf $out/usr
    fi

    # 2. Handle the CLI (Inject your working build)
    find $out -name "opencode-cli" -delete
    mkdir -p $out/bin
    ln -s ${lib.getExe opencode} $out/bin/opencode-cli

    # 3. Handle Main Executable (UI)
    TARGET_BIN=$(find $out/bin -maxdepth 1 -type f ! -name "opencode-cli" -executable | head -n1)

    if [ -z "$TARGET_BIN" ]; then
       TARGET_BIN=$(find $out -type f ! -name "opencode-cli" -executable -name "OpenCode" -o -name "opencode-desktop" | head -n1)
    fi

    if [ -z "$TARGET_BIN" ]; then
      echo "ERROR: Could not find main UI executable"
      exit 1
    fi

    # 4. Wrap Main Binary
    # We construct the GStreamer path using the libraries we imported
    GST_PATH="${
      lib.makeSearchPath "lib/gstreamer-1.0" [
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gstreamer
      ]
    }"

    mv "$TARGET_BIN" "$TARGET_BIN.orig"
    makeWrapper "$TARGET_BIN.orig" "$out/bin/${pname}" \
      --set GDK_BACKEND x11 \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

    # 5. Fix Desktop File
    find $out/share/applications -name "*.desktop" -exec \
      sed -i "s|^Exec=.*|Exec=$out/bin/${pname} %U|" {} \;
      
    find $out/share/applications -name "*.desktop" -exec \
      mv {} $out/share/applications/${pname}.desktop \;

    runHook postInstall
  '';

  meta = with lib; {
    description = "Desktop application for OpenCode AI coding agent";
    homepage = "https://github.com/sst/opencode";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "opencode-desktop";
  };
}
