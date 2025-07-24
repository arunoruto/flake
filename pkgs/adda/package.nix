{
  stdenv,
  lib,
  fetchFromGitHub,
  which,
  gfortran,
  fftw,
  mpi,
  opencl-headers,
  ocl-icd,
  clfft,
  clblas,

  target ? "seq",
# target ? "mpi",
# target ? "ocl",
}:
let
  binaryName =
    if target == "seq" then
      "adda"
    else if target == "mpi" then
      "adda_mpi"
    else if target == "ocl" then
      "adda_ocl"
    else
      throw "Unknown target: ${target}";
  options = builtins.concatStringsSep " " (
    [ "NO_GITHASH" ] ++ (lib.optionals (target == "ocl") [ "OCL_BLAS" ])
  );
  flags = builtins.concatStringsSep " " (
    # create a list of name-value pairs for make flags
    lib.attrsets.mapAttrsToList (name: value: "${name}=${value}") {
      COMPILER = "gnu";
      OPTIONS = ''"${options}"'';
      FORT_LIB_PATH = "${gfortran.cc}/lib";
    }
    ++ [ target ] # append target to the end of the generated list, no name-value pair
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = binaryName;
  # version = "1.4.0";
  version = "1.4.0-unstable-2025-05-26";

  src = fetchFromGitHub {
    owner = "adda-team";
    repo = finalAttrs.pname;
    rev = "ac6c6be366a6f2ec6a096d8adce2ed7fffc417c2";
    hash = "sha256-sXHgAT5khKo5P9jRl7j+LDtfoXuDyttnZK6rbMWt1w4=";
    # tag = "v${finalAttrs.version}";
    # hash = "sha256-mGCWrmdut3sgWATo/Y0HCVlA67425lH8n2A1RdL7Kzg=";
  };

  nativeBuildInputs = [
    which
    gfortran
    fftw
  ]
  ++ (lib.optionals (target == "mpi") [
    mpi
  ])
  ++ (lib.optionals (target == "ocl") [
    opencl-headers
    ocl-icd
    clfft
    clblas
  ]);

  preBuild = ''
    makeFlagsArray+=(${flags})
    cd src/
  '';

  installPhase = ''
    runHook preInstall

    install "${target}/${binaryName}" -Dm755 -t "$out"/bin

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/adda-team/adda";
    description = "light scattering simulator based on the discrete dipole approximation";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ arunoruto ];
    mainProgram = binaryName;
  };
})
