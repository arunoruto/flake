{
  lib,
  stdenv,
  fetchurl,
  patchelf,
  strace,

  glibc,
  zlib,
  ncurses,
  file,
  qt6,
  xorg,
  libxkbcommon,
  at-spi2-atk,
  alsa-lib,
  cups,
  dbus,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dpcpp";
  version = "2025.2.0.527";

  src = fetchurl {
    url = "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/39c79383-66bf-4f44-a6dd-14366e34e255/intel-dpcpp-cpp-compiler-2025.2.0.527_offline.sh";
    sha256 = "sha256-54tgWTlNpmoSetlExYHX2sSNvEreKXv0rhnocHgKFwQ=";
    executable = true;
  };

  # These are build-time dependencies needed for the installation process
  nativeBuildInputs = [
    patchelf
    file
    strace
  ];

  # These are runtime dependencies needed by the final compiler.
  # We also create a `libPath` from them to help patch the installer.
  buildInputs = [
    glibc
    zlib
    ncurses
  ];

  # A helper variable to make RPATHs cleaner. This lists the /lib directories
  # of all runtime dependencies. The installer itself needs some of these.
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    glibc
    zlib
    ncurses
  ];

  installerLibPath = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    glibc
    zlib
    ncurses
    qt6.qtbase
    xorg.libX11
    xorg.libXext
    xorg.libxcb
    xorg.xcbutilkeysyms
    xorg.xcbutilimage
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    libxkbcommon
    at-spi2-atk
    cups
    dbus
    alsa-lib
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true; # Stripping can sometimes break these complex toolchains

  installPhase = ''
    runHook preInstall

    mkdir -p $out/tmp
    local extract_dir="$out/tmp/intel-dpcpp-cpp-compiler-${finalAttrs.version}_offline"

    # 1. Extract the installer's contents.
    bash $src --extract-only --extract-folder $out/tmp -a -s --eula accept

    # 2. Patch ONLY the interpreter for all ELF files in the payload.
    #    We do NOT set the RPATH, as we want to control it entirely with LD_LIBRARY_PATH.
    echo "--- Patching interpreter for installer payload ---"
    find "$extract_dir" -type f -exec file {} + | grep "ELF" | cut -d: -f1 | while read -r elf_file; do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$elf_file" 2>/dev/null || true
    done

    # 3. Set up the environment. CRITICALLY, we OMIT the installer's own `lib` dir.
    export HOME=$out
    export LD_LIBRARY_PATH="${finalAttrs.installerLibPath}" # <-- Note: no ":$extract_dir/lib"

    local bootstrapper="$extract_dir/bootstrapper"

    echo "--- Verifying linker paths for bootstrapper ---"
    echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
    echo "---"
    ldd "$bootstrapper"
    echo "---------------------------------------------"

    # 4. Execute the bootstrapper directly.
    "$bootstrapper" \
      --action install \
      --silent \
      --eula accept \
      --ignore-errors \
      --intel-sw-improvement-program-consent decline \
      --install-dir "$out" \
      --log-dir "$out/tmp" \
      --product-id "intel.oneapi.lin.dpcpp-cpp-compiler.product" \
      --product-ver "2025.2.0+526" \
      --package-path "$extract_dir/packages" \
      --property "ParentProcessName=bootstrapper" | exit 0

    # 5. Clean up.
    rm -rf "$out/tmp"

    runHook postInstall
  '';

  postFixup = ''
    echo "Patching RPATH and interpreter for all ELF files in $out..."
    # Find all ELF files, excluding the temporary installer directory if it's still there
    find "$out" -type f -exec file {} + | grep "ELF" | cut -d: -f1 | while read -r elf_file; do
      echo "Patchelfing $elf_file"
      # Don't try to patch the dynamic linker itself
      if [[ "$(basename "$elf_file")" == "ld-linux-x86-64.so.2" ]]; then
        continue
      fi
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "$out/lib:${finalAttrs.libPath}" \
        "$elf_file" || echo "Patchelf failed on $elf_file, ignoring..."
    done

    # The main clang binary needs an extra library to find libstdc++
    # Find the main clang binary, which is usually in a 'bin' or 'bin-llvm' subdir
    local clang_binary=$(find $out -type f -name "clang" | grep "/bin/clang")
    if [ -n "$clang_binary" ]; then
      echo "Adding libstdc++.so.6 as a needed library for $clang_binary"
      patchelf --add-needed libstdc++.so.6 "$clang_binary"
    fi
  '';

  meta = with lib; {
    homepage = "https://www.intel.com/content/www/us/en/developer/tools/oneapi/dpc-compiler.html";
    description = "Intel's C, C++, SYCL, and Data Parallel C++ (DPC++) compilers for Intel processor-based systems";
    license = licenses.free;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
})
