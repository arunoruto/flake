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
  pname = "wigxjpf";
  version = "1.13";

in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = builtins.fetchTarball {
    url = "http://fy.chalmers.se/subatom/${pname}/${pname}-${version}.tar.gz";
    sha256 = "0nmcld6iaz4hlgf0dy86jsqw8hchlpys89d132azjsa1gw3ddaav";
  };

  # nativeBuildInputs = [
  #   make
  # ];

  # buildInputs = [
  # ];

  # configurePhase = ":";

  # buildPhase = ''
  #   mkdir -p $out
  #   python setup.py install --prefix=$out
  #   # python setup.py install --prefix=$(pwd)

  #   cd build
  #   cmake -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_BUILD_TYPE=Release ..
  #   cp Makefile $out
  #   cp cmake_install.cmake $out
  # '';

  installPhase = ''
    mkdir -p $out
    cd $out
    make -f $src/Makefile VPATH=$src
    # cp -r . $out
  '';

  doCheck = true;
  # checkTarget = "test";

  meta = with lib; {
    homepage = "https://fy.chalmers.se/subatom/wigxjpf/";
    description = "WIGXJPF evaluates Wigner 3j, 6j and 9j symbols accurately using prime factorisation and multi-word integer arithmetic.";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
