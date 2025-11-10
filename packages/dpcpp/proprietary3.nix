{
  lib,
  stdenv,
  fetchurl,
  patchelf,

  # Dependencies needed for both the build and the final product
  glibc,
  zlib,
  ncurses,
  file,
  gawk,
}:

stdenv.mkDerivation rec {
  pname = "intel-dpcpp-cpp-compiler";
  version = "2025.2.0.527";

  src = fetchurl {
    url = "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/39c79383-66bf-4f44-a6dd-14366e34e255/intel-dpcpp-cpp-compiler-2025.2.0.527_offline.sh";
    sha256 = "sha256-54tgWTlNpmoSetlExYHX2sSNvEreKXv0rhnocHgKFwQ=";
    executable = true;
  };

  # Tools needed during the build process
  nativeBuildInputs = [
    patchelf
    file
    gawk
  ];

  # Libraries needed by the final installed compiler
  buildInputs = [
    glibc
    zlib
    ncurses
  ];

  # Helper variable to create a library path for RPATH patching
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    glibc
    zlib
    ncurses
  ];

  # --- Build Control Flags ---
  dontUnpack = true; # We are not a standard archive
  dontConfigure = true; # No ./configure script
  dontBuild = true; # No 'make' step
  dontPatchELF = true; # We do all patching manually for full control
  dontStrip = true; # Stripping can break complex toolchains

  installPhase = ''
    runHook preInstall

    # The installer might need a HOME directory
    export HOME=$(mktemp -d)

    # Copy installer from the read-only Nix store to the writable build dir
    cp $src ./installer.sh
    chmod +x ./installer.sh

    # --- Step 1: Manually extract the embedded archive ---
    # This is necessary because the installer has no reliable --extract-only flag
    # and tries to run its un-patched tools immediately.
    echo "Manually extracting embedded archive from installer.sh..."
    mkdir extract
    # Find the line where the script ends and the binary archive begins
    local skip=$(awk '/^__ARCHIVE_FOLLOWS__/ { print NR; exit 0; }' ./installer.sh)
    # Pipe the archive data to 'tar -x', which auto-detects the compression format
    tail -n +$((skip + 1)) ./installer.sh | tar -x -C extract

    # Find the directory that was just extracted
    local installer_dir=$(find extract -maxdepth 1 -mindepth 1 -type d)
    if [ -z "$installer_dir" ]; then
        echo "ERROR: Failed to manually extract installer contents."
        ls -lR extract
        exit 1
    fi
    echo "Successfully extracted to $installer_dir"

    # --- Step 2: Patch the installer's own tools so they can run ---
    echo "Patching installer scripts and binaries in $installer_dir..."
    # Fix shebangs in any scripts from /bin/sh to the Nix one
    for script in $(grep -l -r "/bin/sh" "$installer_dir"); do
      sed -i -e "s,/bin/sh,${stdenv.shell},g" "$script"
    done

    # Patch the main installer binary ('bootstrapper') to work in the Nix sandbox
    local bootstrapper="$installer_dir/bootstrapper"
    if [ -f "$bootstrapper" ]; then
      echo "Patching bootstrapper: $bootstrapper"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
               --set-rpath "${libPath}:$installer_dir/lib" "$bootstrapper"
    else
      echo "ERROR: Could not find bootstrapper executable!"
      exit 1
    fi

    # --- Step 3: Run the now-patched installer ---
    echo "Running the patched installer..."
    $installer_dir/install.sh -s \
      --eula=accept \
      --install-dir=$out

    runHook postInstall
  '';

  postFixup = ''
    echo "Fixing permissions for patching..."
    # The installer may write read-only files, which prevents patchelf from working.
    chmod -R u+w $out

    echo "Patching final installed ELF files..."
    # This loop finds every binary and library in the final output and makes it
    # compatible with the Nix ecosystem.
    for file in $(find $out -type f -exec file {} + | grep ELF | awk -F: '{print $1}'); do
      echo "  patching: $file"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
               --set-rpath "${libPath}:$out/lib:$out/lib/icx-lto" \
               "$file" 2>/dev/null || true
    done

    # The DPC++ compilers are based on Clang and often need libstdc++ explicitly
    # added to their list of needed libraries.
    for clang_binary in $(find $out -type f -name "icx" -o -name "icpx"); do
      echo "Adding libstdc++.so.6 to $clang_binary"
      patchelf --add-needed libstdc++.so.6 "$clang_binary"
    done
  '';

  meta = with lib; {
    description = "Intel oneAPI DPC++/C++ Compiler";
    homepage = "https://www.intel.com/content/www/us/en/developer/tools/oneapi/dpc-compiler.html";
    # The license is proprietary, not free, even if there's no fee.
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ]; # I've added your handle back
  };
}
