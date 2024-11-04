{
  lib,
  stdenv,
  fetchurl,
  unzip,
  tnt,
}:
let
  pname = "jama";
  version = "125";
in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = fetchurl {
    url = "https://math.nist.gov/tnt/${pname}${version}.zip";
    sha256 = "031ns526fvi2nv7jzzv02i7i5sjcyr0gj884i3an67qhsx8vyckl";
  };

  nativeBuildInputs = [ unzip ];
  propagatedBuildInputs = [ tnt ];

  unpackPhase = ''
    mkdir "${pname}-${version}"
    unzip "$src"
  '';
  installPhase = ''
    mkdir -p $out/include/jama
    cp *.h $out/include/jama
  '';

  meta = with lib; {
    homepage = "https://math.nist.gov/tnt/";
    description = "JAMA/C++ Linear Algebra Package: Java-like matrix C++ templates";
    platforms = platforms.unix;
    license = licenses.publicDomain;
  };
}
