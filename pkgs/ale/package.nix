{
  lib,
  stdenv,
  fetchFromGitHub,
  ensureNewerSourcesHook,

  cmake,
  doxygen,
  eigen,
  gtest,
  nlohmann_json,
  python311,
  python311Packages,
  sphinx,
}:
let
  pname = "ale";
  version = "0.10.0";

in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    owner = "DOI-USGS";
    repo = pname;
    rev = version;
    hash = "sha256-eEsdkIUG7ocFPPkNkNhSbkc7+bIEMi3WBd24wNyDk0I=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    doxygen
    eigen
    gtest
    nlohmann_json
    python311
    python311Packages.breathe
    python311Packages.setuptools
    sphinx
  ];

  buildInputs = [
    (ensureNewerSourcesHook { year = "1980"; })
  ];

  configurePhase = ":";

  buildPhase = ''
    mkdir -p $out
    python setup.py install --prefix=$out
    # python setup.py install --prefix=$(pwd)

    cd build
    cmake -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_BUILD_TYPE=Release ..
    cp Makefile $out
    cp cmake_install.cmake $out
  '';

  installPhase = ''
    make install
  '';

  doCheck = true;
  checkTarget = "test";

  meta = with lib; {
    homepage = "https://github.com/DOI-USGS/ale";
    description = "Abstraction Layer for Ephemerides (ALE)";
    license = licenses.cc0;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
