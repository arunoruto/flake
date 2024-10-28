{
  lib,
  stdenv,
  alsa-lib,
  atk,
  cairo,
  cups,
  dbus,
  dbus-glib,
  ffmpeg,
  fontconfig,
  freetype,
  gdk-pixbuf,
  gtk3,
  glib,
  icu73,
  jemalloc,
  libGL,
  libGLU,
  libdrm,
  libevent,
  libffi,
  libglvnd,
  libjack2,
  libjpeg,
  libkrb5,
  libnotify,
  libpng,
  libpulseaudio,
  libstartup_notification,
  libva,
  libvpx,
  libwebp,
  libxkbcommon,
  libxml2,
  makeWrapper,
  mesa,
  # nasm,
  nspr,
  nss_latest,
  pango,
  pciutils,
  pipewire,
  sndio,
  udev,
  xcb-util-cursor,
  xorg,
  zlib,

  alsaSupport ? stdenv.hostPlatform.isLinux,
  ffmpegSupport ? true,
  gssSupport ? true,
  jackSupport ? stdenv.hostPlatform.isLinux,
  jemallocSupport ? !stdenv.hostPlatform.isMusl,
  pulseaudioSupport ? stdenv.hostPlatform.isLinux,
  sndioSupport ? stdenv.hostPlatform.isLinux,
  waylandSupport ? true,

  privacySupport ? false,

  # WARNING: NEVER set any of the options below to `true` by default.
  # Set to `!privacySupport` or `false`.
  geolocationSupport ? !privacySupport,
  webrtcSupport ? !privacySupport,
}:
stdenv.mkDerivation rec {
  pname = "zen-browser";
  version = "1.0.1-a.13";

  src = builtins.fetchTarball {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-specific.tar.bz2";
    sha256 = "0r9jyc82hlz6jav9kzygnz3gdd7vci0m3im5zh1kynvfn18k7nys";
  };

  buildInputs =
    [
      makeWrapper
      atk
      cairo
      cups
      dbus
      dbus-glib
      ffmpeg
      fontconfig
      freetype
      gdk-pixbuf
      gtk3
      glib
      icu73
      libGL
      libGLU
      libevent
      libffi
      libglvnd
      libjpeg
      libnotify
      libpng
      libstartup_notification
      libva
      libvpx
      libwebp
      libxml2
      mesa
      nspr
      nss_latest
      pango
      pciutils
      pipewire
      udev
      xcb-util-cursor
      xorg.libX11
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXft
      xorg.libXi
      xorg.libXrender
      xorg.libXt
      xorg.libXtst
      xorg.pixman
      xorg.xorgproto
      xorg.libxcb
      xorg.libXrandr
      xorg.libXcomposite
      xorg.libXfixes
      xorg.libXScrnSaver
      zlib
    ]
    ++ lib.optional alsaSupport alsa-lib
    ++ lib.optional jackSupport libjack2
    ++ lib.optional pulseaudioSupport libpulseaudio
    ++ lib.optional sndioSupport sndio
    ++ lib.optional gssSupport libkrb5
    ++ lib.optional jemallocSupport jemalloc
    ++ lib.optionals waylandSupport [
      libdrm
      libxkbcommon
    ];

  configureFlags =
    [
      "--disable-bootstrap"
      "--disable-updater"
      "--enable-default-toolkit=cairo-gtk3${lib.optionalString waylandSupport "-wayland"}"
      "--enable-system-pixman"
      "--with-distribution-id=org.nixos"
      # "--with-libclang-path=${llvmPackagesBuildBuild.libclang.lib}/lib"
      "--with-system-ffi"
      "--with-system-icu"
      "--with-system-jpeg"
      "--with-system-libevent"
      "--with-system-libvpx"
      "--with-system-nspr"
      "--with-system-nss"
      "--with-system-png" # needs APNG support
      "--with-system-webp"
      "--with-system-zlib"
      # "--with-wasi-sysroot=${wasiSysRoot}"
      # "--host=${buildStdenv.buildPlatform.config}"
      # "--target=${buildStdenv.hostPlatform.config}"
    ]
    ++ [
      (lib.enableFeature alsaSupport "alsa")
      (lib.enableFeature ffmpegSupport "ffmpeg")
      (lib.enableFeature geolocationSupport "necko-wifi")
      (lib.enableFeature gssSupport "negotiateauth")
      (lib.enableFeature jackSupport "jack")
      (lib.enableFeature jemallocSupport "jemalloc")
      (lib.enableFeature pulseaudioSupport "pulseaudio")
      (lib.enableFeature sndioSupport "sndio")
      (lib.enableFeature webrtcSupport "webrtc")
      # --enable-release adds -ffunction-sections & LTO that require a big amount
      # of RAM, and the 32-bit memory space cannot handle that linking
      # (lib.enableFeature (!debugBuild && !stdenv.hostPlatform.is32bit) "release")
      # (lib.enableFeature enableDebugSymbols "debug-symbols")
    ];

  installPhase = ''
    # runHook preInstall

    mkdir -p $out/bin
    cp -r . $out/bin

    wrapProgram $out/bin/zen \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath buildInputs}"

    # runHook postInstall
  '';

  # passthru = {
  #   inherit gtk3;
  # };

  meta = with lib; {
    homepage = "https://zen-browser.app/";
    description = "🌀 Experience tranquillity while browsing the web without people tracking you!";
    license = licenses.mpl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
