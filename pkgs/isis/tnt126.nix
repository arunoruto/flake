{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:
let
  pname = "tnt";
  version = "126";
in
stdenv.mkDerivation {
  inherit version;
  inherit pname;
  # pname = "${pname}_${version}";

  src = fetchurl {
    url = "https://math.nist.gov/tnt/${pname}_${version}.zip";
    hash = "sha256-k8fN0Ram+utnmJClLVtRMFU4jH+qrHS+6lcPjy7b1+Q=";
  };

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  sourceRoot = ".";

  buildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/include/tnt
    cp *.h $out/include/tnt
  '';

  meta = with lib; {
    homepage = "https://math.nist.gov/tnt/";
    description = "Template Numerical Toolkit: C++ headers for array and matrices";
    maintainers = with maintainers; [ arunoruto ];
    license = licenses.publicDomain;
    platforms = platforms.unix;
  };
}
