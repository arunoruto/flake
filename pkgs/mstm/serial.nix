{
  stdenv,
  lib,
  fetchFromGitHub,
  gfortran,
}:
stdenv.mkDerivation rec {
  pname = "mstm";
  version = "v4.0.0";
  # version = "4-2024-02-08";

  src = fetchFromGitHub {
    owner = "dmckwski";
    repo = pname;
    rev = version;
    hash = "sha256-gIlZMHE7vNDtRtzdYRtXeo+PBgJHi911AJaXzMn/wpI=";
  };

  nativeBuildInputs = [
    gfortran
  ];

  buildPhase = ''
    cd ./code
    gfortran -O2 -fallow-argument-mismatch -c -o mstm-intrinsics.obj mstm-intrinsics.f90
    gfortran -O2 -fallow-argument-mismatch -c -o mpidefs-serial.obj mpidefs-serial.f90
    gfortran -O2 -fallow-argument-mismatch -c -o mstm.obj mstm-v4.0.f90
    gfortran -O2 -fallow-argument-mismatch -o mstm mstm-intrinsics.obj mpidefs-serial.obj mstm.obj
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/dmckwski/MSTM";
    description = "Multiple Sphere T Matrix code in Fortran";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [arunoruto];
  };
}
