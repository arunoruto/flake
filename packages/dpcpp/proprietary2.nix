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

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true; # Stripping can sometimes break these complex toolchains

  installPhase = ''
    runHook preInstall

    mkdir -p $out/tmp

    # Extract files
    bash $src --log $out/basekit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp -s --eula accept

    for file in `grep -l -r "/bin/sh" $out/tmp`
    do
      sed -e "s,/bin/sh,${stdenv.shell},g" -i $file
    done
    export HOME=$out
    # Patch the bootstraper binaries and libs
    for files in `find $out/tmp/intel-dpcpp-cpp-compiler-${finalAttrs.version}_offline/lib`
    do
      patchelf --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-dpcpp-cpp-compiler-${finalAttrs.version}_offline/lib" $file 2>/dev/null || true
    done
    echo $NIX_CC
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${glibc}/lib:$libPath:$out/tmp/intel-dpcpp-cpp-compiler-${finalAttrs.version}_offline/lib" $out/tmp/intel-dpcpp-cpp-compiler-${finalAttrs.version}_offline/bootstrapper

    # launch install
    export LD_LIBRARY_PATH=${zlib}/lib
    strace -f -o $out/tmp/intel-dpcpp-cpp-compiler-${finalAttrs.version}_offline/install.sh \
      --action install \
      --silent \
      --eula accept \
      --ignore-errors \
      --intel-sw-improvement-program-consent decline \
      --install-dir $out

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
