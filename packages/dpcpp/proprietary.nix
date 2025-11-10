{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,

  ncurses,
  xorg,
}:
let
  pname = "dpcpp";
  version = "2025.0.4.20";

  installer = stdenv.mkDerivation {
    name = "${pname}-installer-${version}";

    src = fetchurl {
      url = "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/84c039b6-2b7d-4544-a745-3fcf8afd643f/intel-${pname}-cpp-compiler-${version}_offline.sh";
      sha256 = "A8qubgwz5h0SoFSrnFyDkZzdfSW3OSl3keR3dOx/ti0=";
      executable = true;
    };

    unpackPhase = ''
      mkdir -p $out
      $src -x -f $out
    '';

    nativeBuildInputs = [
      autoPatchelfHook
      ncurses
      stdenv.cc.cc.lib
      xorg.libXau
    ];
  };
in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = installer;

  dontPatchELF = true;

  nativeBuildInputs = [
    # autoPatchelfHook
    # ncurses
  ];

  unpackPhase = ":";

  # configurePhase = ":";

  # buildPhase = ''
  # '';

  installPhase = ''
    mkdir -p $out
    ls -la $src/intel-dpcpp-cpp-compiler-${version}_offline/install.sh
    $src/intel-dpcpp-cpp-compiler-${version}_offline/install.sh -s \
      --eula=accept \
      --log-dir=/build/log \
      --install-dir=$out
  '';

  # postInstallPhase = ''
  # '';

  meta = with lib; {
    homepage = "https://www.intel.com/content/www/us/en/developer/tools/oneapi/dpc-compiler.html";
    description = "Intel's C, C++, SYCL, and Data Parallel C++ (DPC++) compilers for Intel processor-based systems";
    license = licenses.free;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
