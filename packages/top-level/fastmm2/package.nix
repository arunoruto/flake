{
  lib,
  stdenv,
  fetchFromBitbucket,
  cmake,
  blas,
  lapack,
  gfortran,
  hdf5-fortran,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fastmm2";
  version = "0-unstable-2026-06-09";

  src = fetchFromBitbucket {
    owner = "planetarysystemresearch";
    repo = "FaSTMM2";
    rev = "4b56dc5b30333f3358e205ba8f88a03ee4d2bb3b";
    hash = "sha256-pBWNXhEJhrfmoZJctI38Zafg88uIPEkc1ePbRIoxQcI=";
  };

  cmakeDir = "../src";
  cmakeFlags = [
    "--no-warn-unused-cli"
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ];

  nativeBuildInputs = [
    cmake
    blas
    lapack
    gfortran
    hdf5-fortran
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp FaSTMM2 $out/bin/

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    echo "Running binary sanity check..."

    $out/bin/FaSTMM2 2>&1 | grep "Cannot find file:geometry.h5" > /dev/null

    echo "Sanity check passed!"

    runHook postInstallCheck
  '';

  meta = {
    description = "Fast Superposition T-Matrix Method";
    homepage = "https://bitbucket.org/planetarysystemresearch/fastmm2";
    # license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    mainProgram = "FaSTMM2";
  };
})
