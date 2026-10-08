{
  lib,
  stdenvNoCC,
  buildFHSEnv,
  fetchMatlab,
  makeDesktopItem,
  mpm,
  release ? "R2025a",
  update ? 1,
  hash ? "sha256-uVhTEovwJsVye7DukMhmUhsDmtuuNEQQy71PBniaEbU=",
  # Toolboxes to install alongside MATLAB, as product name -> hash of its download.
  products ? { },
  licenseFile ? null,
}:

let
  version = "${release}U${toString update}";

  base = fetchMatlab { inherit release update hash; };
  sources = [
    base
  ]
  ++ lib.mapAttrsToList (
    product: hash:
    fetchMatlab {
      inherit
        release
        update
        product
        hash
        ;
    }
  ) products;

  # mpm runs bin/glnxa64/registerWithOS from the fresh install, which needs an FHS system.
  installEnv = buildFHSEnv {
    name = "matlab-install-env";
    targetPkgs = p: [
      p.pam
      p.zlib
    ];
    runScript = "bash";
  };

  unwrapped = stdenvNoCC.mkDerivation {
    pname = "matlab-unwrapped";
    inherit version;

    __structuredAttrs = true;
    strictDeps = true;

    dontUnpack = true;
    dontFixup = true;

    # Only MATLAB's ProductFilesInfo.xml is kept: mpm validates its checksum,
    # and installs every product it finds in the merged archives anyway.
    # Files shared between downloads are identical, so the first one wins.
    installPhase = ''
      runHook preInstall

      export HOME=$TMPDIR
      mkdir source
      cp ${base}/ProductFilesInfo.xml source/
      for src in ${lib.escapeShellArgs sources}; do
        cp -rs --update=none --no-preserve=mode "$src/archives" source/
      done

      ${installEnv}/bin/matlab-install-env -c '${lib.getExe mpm} install \
        --source="$PWD/source" \
        --destination="$out" \
        --support-package-destination="$out/SupportPackages" \
        --products MATLAB ${lib.escapeShellArgs (lib.attrNames products)}'

      runHook postInstall
    '';
  };

  desktopItem = makeDesktopItem {
    name = "matlab";
    desktopName = "MATLAB ${release}";
    exec = "matlab -desktop -useStartupFolderPref %F";
    icon = "${unwrapped}/ui/icons/16x16/matlabLogoUI.svg";
    categories = [
      "Science"
      "Math"
    ];
  };
in
buildFHSEnv {
  pname = "matlab";
  inherit version;

  # MathWorks' matlab-deps list (R2025a + R2026a, ubuntu24.04), plus the extras
  # nix-matlab needed over the years.
  targetPkgs =
    p: with p; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cacert
      cairo
      cups
      dbus
      fontconfig
      fribidi
      gdk-pixbuf
      glib
      glibcLocales
      gst_all_1.gst-plugins-base
      gst_all_1.gstreamer
      gtk3
      hidapi
      libcap
      libdrm
      libgbm
      libglvnd
      libpsm2
      libsndfile
      libtirpc
      libtool # libltdl
      libuuid
      libxcrypt
      libxcrypt-legacy
      libxkbcommon
      ncurses # terminal UI
      nspr
      nss
      numactl
      pam
      pango
      pixman
      procps
      rdma-core # libibverbs, librdmacm
      stdenv.cc.cc.lib # libatomic
      ucx
      udev
      unzip
      wayland
      which
      xkbcomp
      xkeyboard_config
      zlib

      libice
      libsm
      libx11
      libxcb
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxfont_2
      libxft
      libxi
      libxinerama
      libxrandr
      libxrender
      libxt
      libxtst
      libxxf86vm

      # mex
      gcc
      gfortran
      gnumake
    ];

  profile = ''
    # The session's LD_LIBRARY_PATH (pipewire-jack, sane, alsa) makes MATLAB
    # exit silently. The FHS ld.so.conf already covers /run/opengl-driver/lib.
    unset LD_LIBRARY_PATH
    # The MathWorks Service Host, which MATLAB installs into ~/.MathWorks at
    # runtime, ships libraries requiring an executable stack (glibc >= 2.41).
    export GLIBC_TUNABLES=glibc.rtld.execstack=2
    # Java GUIs render blank under non-reparenting compositors (niri, sway, ...)
    export _JAVA_AWT_WM_NONREPARENTING=1
    export MW_ALLOW_ANY_CUDA=1
    ${lib.optionalString (licenseFile != null) ''
      export MLM_LICENSE_FILE=${toString licenseFile}
    ''}
  '';

  runScript = "${unwrapped}/bin/matlab";

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications/
  '';

  passthru = { inherit unwrapped sources; };

  meta = {
    description = "MATLAB, installed from per-product mpm downloads";
    homepage = "https://www.mathworks.com/products/matlab.html";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "matlab";
  };
}
