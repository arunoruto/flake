{
  lib,
  buildFHSEnv,
  makeDesktopItem,
  mpm,
  symlinkJoin,
  writeShellScript,
  writeShellScriptBin,
  release ? "R2025a",
  # Products `matlab-sync` makes sure are installed, besides MATLAB itself.
  products ? [ ],
  licenseFile ? null,
}:

# MATLAB itself lives in the user's home, installed and extended with mpm like
# Steam manages its games; this package only provides the FHS environment.
let
  root = ''"''${MATLAB_ROOT:-''${XDG_DATA_HOME:-$HOME/.local/share}/matlab/${release}}"'';

  env = buildFHSEnv {
    name = "matlab-env";

    # MathWorks' matlab-deps list (R2025a + R2026a, ubuntu24.04), plus the
    # extras nix-matlab needed over the years. MATLAB and the binaries
    # `mpm install` runs from a fresh install (registerWithOS) expect an FHS system.
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
        mpm
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
      ${lib.optionalString (licenseFile != null) ''
        export MLM_LICENSE_FILE=${toString licenseFile}
      ''}
    '';

    runScript = "bash";
  };

  launcher = writeShellScript "matlab-launcher" ''
    root=${root}
    if [ ! -x "$root/bin/matlab" ]; then
      echo "MATLAB ${release} is not installed in $root; run matlab-sync first." >&2
      exit 1
    fi

    # Without a display MATLAB renders its desktop on an invisible Xvfb of its
    # own, so it looks like nothing happens; fall back to the terminal instead.
    if [ -z "''${DISPLAY:-}" ] && [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      mode=
      for arg in "$@"; do
        case "''${arg,,}" in
          -nodesktop | -nodisplay | -batch | -nojvm) mode=1 ;;
        esac
      done
      if [ -z "$mode" ]; then
        echo "No display found, starting MATLAB in the terminal (use ssh -Y for the desktop)." >&2
        set -- -nodesktop "$@"
      fi
    fi

    exec "$root/bin/matlab" "$@"
  '';

  # Installs MATLAB and every missing product into the root; extra products can
  # be passed as arguments. Anything else is managed from within MATLAB.
  sync = writeShellScript "matlab-sync" ''
    set -euo pipefail
    root=${root}
    wanted=(MATLAB ${lib.escapeShellArgs products} "$@")

    # `mpm list` prints product names with spaces instead of underscores.
    installed=$(mpm list --matlabroot="$root" 2>/dev/null || true)
    missing=()
    for product in "''${wanted[@]}"; do
      if ! grep -qxF -- "''${product//_/ }" <<<"$installed"; then
        missing+=("$product")
      fi
    done

    if [ ''${#missing[@]} -eq 0 ]; then
      echo "MATLAB ${release} in $root has everything: ''${wanted[*]}"
    else
      echo "Installing into $root: ''${missing[*]}"
      mpm install --release=${release} --destination="$root" --products "''${missing[@]}"
    fi

    # Let the desktop entry find MATLAB's logo.
    install -Dm644 "$root/ui/icons/16x16/matlabLogoUI.svg" \
      "''${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/apps/matlab.svg"
  '';

  desktopItem = makeDesktopItem {
    name = "matlab";
    desktopName = "MATLAB ${release}";
    exec = "matlab -desktop -useStartupFolderPref %F";
    icon = "matlab";
    categories = [
      "Science"
      "Math"
    ];
  };
in
symlinkJoin {
  pname = "matlab";
  version = release;

  paths = [
    (writeShellScriptBin "matlab" ''exec ${lib.getExe env} ${launcher} "$@"'')
    (writeShellScriptBin "matlab-sync" ''exec ${lib.getExe env} ${sync} "$@"'')
    desktopItem
  ];

  passthru = { inherit env; };

  meta = {
    description = "MATLAB in an FHS environment, installed per user with mpm";
    homepage = "https://www.mathworks.com/products/matlab.html";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "matlab";
  };
}
