{
  lib,
  stdenv,
  fetchFromGitHub,

  cmake,
  python3,
  ninja,
  hwloc,
  perl,

  level-zero,
}:
let
  date = "2024-12-19";

  vc-intrinsics = fetchFromGitHub {
    owner = "intel";
    repo = "vc-intrinsics";
    rev = "v0.21.0";
    sha256 = "sha256-Ujekj1EeUuOsb1dXMk9XYYe0b1ZzKU7xygLkH8F71d8=";
  };

  unified-runtime = fetchFromGitHub {
    owner = "oneapi-src";
    repo = "unified-runtime";
    rev = "v0.11.1";
    sha256 = "sha256-WxbkisEZNTvZ+4xa/cUjaaTDWY3rOCdJraxKtRqbZL0=";
  };

  compute-runtime = fetchFromGitHub {
    owner = "intel";
    repo = "compute-runtime";
    rev = "24.39.31294.12";
    sha256 = "sha256-7GNtAo20DgxAxYSPt6Nh92nuuaS9tzsQGH+sLnsvBKU=";
  };
in
stdenv.mkDerivation {
  pname = "dpcpp";
  version = "0-unstable-${date}";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "llvm";
    rev = "nightly-${date}";
    sha256 = "rtGeE/7cTSgTg+KxuZOfc6HDHG4Fgte0jjh4nYLo/E8=";
  };

  buildInputs = [
    level-zero
  ];

  nativeBuildInputs = [
    cmake
    python3
    ninja
    hwloc
    perl
  ];

  unpackPhase = ":";

  configurePhase = ":";

  buildPhase = ''
    export LEVEL_ZERO_DIR=${level-zero}
    python3 $src/buildbot/configure.py \
      --obj-dir=$PWD \
      --cmake-opt="-DLLVMGenXIntrinsics_SOURCE_DIR=${vc-intrinsics}" \
      --cmake-opt="-DSYCL_UR_USE_FETCH_CONTENT=OFF" \
      --cmake-opt="-DSYCL_UR_SOURCE_DIR=${unified-runtime}" \
      --cmake-opt="-DUR_LEVEL_ZERO_LOADER_LIBRARY=${level-zero}/lib" \
      --cmake-opt="-DUR_LEVEL_ZERO_INCLUDE_DIR=${level-zero}" \
      --cmake-opt="-DCOMPUTE_RUNTIME_LEVEL_ZERO_INCLUDE=${compute-runtime}"
    python3 $src/buildbot/compile.py
  '';

  # installPhase = ''
  # '';

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
