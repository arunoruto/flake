{
  lib,
  stdenv,

  autoPatchelfHook,

  # cudatoolkit,
  level-zero,
  libxml2,
  libz,
  ocl-icd,
  rocmPackages,
}:
let
  date = "2024-12-19";
in
stdenv.mkDerivation {
  pname = "dpcpp";
  version = "0-unstable-${date}";

  src = builtins.fetchTarball {
    url = "https://github.com/intel/llvm/releases/download/nightly-${date}/sycl_linux.tar.gz";
    sha256 = "sha256:1bkdn4bcml1n665rl435zf59gkxy9kc1b8bbdzmdb5p000wqq051";
  };

  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"
    "libcudart.so.1"
  ];

  buildInputs = [
    # cudatoolkit
    level-zero
    libxml2
    libz
    ocl-icd
    rocmPackages.clr
    stdenv.cc.cc
  ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';

  meta = with lib; {
    homepage = "https://www.intel.com/content/www/us/en/developer/tools/oneapi/dpc-compiler.html";
    description = "Intel's C, C++, SYCL, and Data Parallel C++ (DPC++) compilers for Intel processor-based systems";
    license = licenses.free;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
