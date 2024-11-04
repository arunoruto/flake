{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,

  # build
  cmake,
  ninja,
  ale,
  armadillo,
  blas,
  boost,
  csm,
  cspice,
  bullet,
  doxygen,
  eigen,
  embree,
  gsl,
  gtest,
  hdf5,
  inja,
  jama,
  lapack,
  libgeotiff,
  libtiff,
  nanoflann,
  nn,
  protobuf,
  python3,
  pcl,
  qt5,
  suitesparse,
  superlu,
  tnt,
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

  embree3 = embree.overrideAttrs (
    finalAttrs: previousAttrs: {
      version = "3.13.0";
      src = fetchFromGitHub {
        owner = "RenderKit";
        repo = previousAttrs.pname;
        rev = "v${finalAttrs.version}";
        sha256 = "sha256-w93GYslQRg0rvguMKv/CuT3+JzIis2CRbY9jYUFKWOM=";
      };
      postPatch = ''
        # Fix duplicate /nix/store/.../nix/store/.../ paths
        sed -i "s|SET(EMBREE_ROOT_DIR .*)|set(EMBREE_ROOT_DIR $out)|" \
          common/cmake/embree-config.cmake
        sed -i "s|$""{EMBREE_ROOT_DIR}/||" common/cmake/embree-config.cmake
        substituteInPlace common/math/math.h --replace 'defined(__MACOSX__) && !defined(__INTEL_COMPILER)' 0
        substituteInPlace common/math/math.h --replace 'defined(__WIN32__) || defined(__FreeBSD__)' 'defined(__WIN32__) || defined(__FreeBSD__) || defined(__MACOSX__)'
      '';
    }
  );
  tnt126 = tnt.overrideAttrs (
    finalAttrs: previousAttrs: {
      version = "1.2.6";
      src = fetchurl {
        url = "https://math.nist.gov/tnt/tnt_126.zip";
        hash = "sha256-k8fN0Ram+utnmJClLVtRMFU4jH+qrHS+6lcPjy7b1+Q=";
      };
      # Work around the "unpacker appears to have produced no directories"
      # case that happens when the archive doesn't have a subdirectory.
      sourceRoot = ".";
      installPhase = ''
        mkdir -p $out/include/tnt
        cp *.h $out/include/tnt
      '';
    }
  );
  jama125 = jama.overrideAttrs (
    finalAttrs: previousAttrs: {
      propagatedBuildInputs = [ tnt126 ];
      installPhase = ''
        mkdir -p $out/include/jama
        cp *.h $out/include/jama
      '';
    }
  );
  nn1860 = nn.overrideAttrs (
    finalAttrs: previousAttrs: {
      version = "1.86.0";
      src = fetchFromGitHub {
        owner = "sakov";
        repo = "nn-c";
        rev = "33cbf70dec4f64836a26dcb4a885cb09b7279dd3";
        hash = "sha256-fDXAM2IDvCH1RZ2kEp/UlUin/YMRSnMBgitz1apw6Gk=";
      };
    }
  );
  nanoflann132 = nanoflann.overrideAttrs (
    finalAttrs: previousAttrs: {
      version = "1.3.2";
      src = fetchFromGitHub {
        owner = "jlblancoc";
        repo = previousAttrs.pname;
        rev = "v${finalAttrs.version}";
        sha256 = "sha256-VsNldy7cR9ECbM+ixVkhey+s5SlcnQZL2BzNLTn+AVM=";
      };
    }
  );

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
    csm
    cspice
    doxygen
    eigen
    embree3
    gsl
    gtest
    hdf5
    inja
    jama125
    lapack
    libgeotiff
    libtiff
    libsForQt5.qt5.qttools
    libsForQt5.qt5.qtxmlpatterns
    libsForQt5.qtutilities
    libsForQt5.qwt
    nanoflann132
    nn1860
    opencv
    pcl
    protobuf
    python3
    qt5.qtbase
    qt5.qtmultimedia
    qt5.qtquick3d
    qt5.qtscript
    qt5.qtsvg
    qt5.qtwebchannel
    suitesparse
    superlu
    tnt126
    swig
    xalanc
  ];

  buildInputs = [
    geos
    xercesc
  ];

  # phases = [
  #   "unpackPhase"
  #   "preBuild"
  #   "buildPhase"
  #   "preInstall"
  #   "installPhase"
  # ];
  dontWrapQtApps = true;
  configurePhase = ":";

  preBuild = ''
    mkdir -p build/lib install
    export ISISROOT=$(pwd)
  '';

  buildPhase = ''
    runHook preBuild
    cd ./build
    cmake -DJP2KFLAG=OFF -DBUILDTESTS=OFF -DPYBINDINGS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(pwd)/../install -GNinja ../isis
  '';

  preInstall = ''
    substituteInPlace \
      ../isis/src/base/objs/EmbreeTargetShape/EmbreeTargetShape.cpp \
      --replace-fail "isinf" "std::isinf"
    export ISISROOT=$(pwd)
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    ninja install
    cp -r ../install/* $out
  '';

  meta = with lib; {
    homepage = "https://isis.astrogeology.usgs.gov";
    description = "A digital image processing software package to manipulate imagery collected by current and past NASA and International planetary missions";
    license = licenses.cc0;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
