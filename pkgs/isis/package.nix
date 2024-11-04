{
  lib,
  stdenv,
  fetchFromGitHub,

  # build
  cmake,
  ninja,
  ale,
  armadillo,
  blas,
  boost,
  bullet,
  doxygen,
  embree,
  gsl,
  gtest,
  hdf5,
  inja,
  jama,
  lapack,
  libtiff,
  nanoflann,
  nn,
  protobuf,
  python3,
  pcl,
  qt5,
  superlu,
  swig,
  xalanc,

  # runtime
  geos,
  opencv,
  xercesc,
  libsForQt5,
}:
let
  pname = "isis";
  version = "8.3.0";

in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    owner = "DOI-USGS";
    repo = "ISIS3";
    rev = version;
    hash = "sha256-lJt76aRWPfQSAZesXg2zouWu73cdD+GVNEZgmR30GWo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    ale
    armadillo
    blas
    boost
    bullet
    doxygen
    embree
    gsl
    gtest
    hdf5
    inja
    jama
    lapack
    libtiff
    libsForQt5.qt5.qttools
    libsForQt5.qt5.qtxmlpatterns
    libsForQt5.qtutilities
    libsForQt5.qwt
    nanoflann
    nn
    opencv
    pcl
    protobuf
    python3
    qt5.qtbase
    # qt5.qtgui
    qt5.qtmultimedia
    # qt5.qtnetwork
    # qt5.qtopengl
    # qt5.qtprintsupport
    # qt5.qtqml
    qt5.qtquick3d
    qt5.qtscript
    # qt5.qtsql
    qt5.qtsvg
    # qt5.qttest
    qt5.qtwebchannel
    # qt5.qtxml
    superlu
    swig
    xalanc
  ];

  buildInputs = [
    geos
    xercesc
  ];

  phases = [
    "unpackPhase"
    "preBuild"
    "buildPhase"
    "installPhase"
  ];
  # configurePhase = ":";

  preBuild = ''
    mkdir build install
    export ISISROOT=$(pwd)

    ls /etc

    # mkdir /etc
    # mkdir ../../etc
    # cat >> /etc/os-release << EOF
    # NAME=NixOS
    # VERSION="24.05 (Uakari)"
    # EOF
  '';

  buildPhase = ''
    # runHook preBuild
    cd ./build
    cmake -DJP2KFLAG=OFF -DBUILDTESTS=OFF -DPYBINDINGS=OFF -GNinja ../isis
  '';

  installPhase = ''
    mkdir $out
    cp -r . $out
  '';

  meta = with lib; {
    homepage = "https://isis.astrogeology.usgs.gov";
    description = "A digital image processing software package to manipulate imagery collected by current and past NASA and International planetary missions";
    license = licenses.cc0;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
