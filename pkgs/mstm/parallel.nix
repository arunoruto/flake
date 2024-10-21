{
  stdenv,
  lib,
  makeWrapper,
  fetchFromGitHub,
  gfortran,
  mpi,
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

  buildInputs = [
    makeWrapper
  ];

  nativeBuildInputs = [
    gfortran
    mpi
  ];

  preInstallPhase = ''
    mkdir -p $out/bin
    cat >> $out/bin/mstm << EOF
    #!/usr/bin/env bash

    if [[ \$# -eq 1 ]]; then
    mpiexec -n 4 $out/bin/mstm-mpi \$1
    else
    mpiexec -n \$1 $out/bin/mstm-mpi \$2
    fi
    EOF
    chmod +x $out/bin/mstm
  '';

  buildPhase = ''
    cd ./code
    mpif90 -O2 -fallow-argument-mismatch -c -o mstm-intrinsics.obj mstm-intrinsics.f90
    mpif90 -O2 -fallow-argument-mismatch -c -o mpidefs-parallel.obj mpidefs-parallel.f90
    mpif90 -O2 -fallow-argument-mismatch -c -o mstm.obj mstm-v4.0.f90
    mpif90 -O2 -fallow-argument-mismatch -o mstm-mpi mstm-intrinsics.obj mpidefs-parallel.obj mstm.obj
  '';

  installPhase = ''
    runHook preInstallPhase

    mkdir -p $out/bin
    cp ${pname}-mpi $out/bin

    runHook postInstallPhase
  '';

  postInstallPhase = ''
    wrapProgram $out/bin/mstm \
      --prefix PATH : ${lib.makeBinPath [mpi]}
  '';

  meta = with lib; {
    homepage = "https://github.com/dmckwski/MSTM";
    description = "Multiple Sphere T Matrix code in Fortran - parallel edition";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [arunoruto];
  };
}
