{
  lib,
  stdenv,
  fetchFromGitHub,

  cmake,
  sqlite,
}:
let
  pname = "csm";
  version = "3.0.3-dec";

in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    owner = "USGS-Astrogeology";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ol+jJNTc9lHf93WbIl6jSmbUNVnW7xsy1TTQ3HsX6ac=";
  };

  # src =
  #   (fetchFromGitHub {
  #     owner = "DOI-USGS";
  #     repo = "usgs${pname}";
  #     rev = version;
  #     hash = "sha256-MtdgWm5qvBbqHVQfJLXS9S1lVlFbkLnAlGrpUZn1pwo=";
  #     fetchSubmodules = true;
  #   }).overrideAttrs
  #     (_: {
  #       GIT_CONFIG_COUNT = 1;
  #       GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
  #       GIT_CONFIG_VALUE_0 = "git@github.com:";
  #     });

  nativeBuildInputs =
    [
    ];

  buildInputs =
    [
    ];

  configurePhase = ":";

  buildPhase = ''
    make -f Makefile.linux64 all install clean
  '';

  installPhase = ''
    mkdir $out
    cp -r ./linux64/* $out
  '';

  # doCheck = true;
  # checkTarget = "test";

  meta = with lib; {
    homepage = "https://github.com/USGS-Astrogeology/csm";
    description = "Community Sensor Model";
    license = licenses.publicDomain;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
