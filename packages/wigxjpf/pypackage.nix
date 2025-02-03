{
  lib,
  buildPythonPackage,
  fetchPypi,

  # dependencies
  cffi,
  pycparser,
  numpy,
}:
let
  pname = "pywigxjpf";
  version = "1.13.3";
in
buildPythonPackage {
  inherit pname version;
  format = "setuptools";
  src = fetchPypi {
    inherit pname version;
    extension = "tar.gz";
    hash = "sha256-MBIsmrJ3WqigUx0BlWiSYn8cboK6ZcOr9rj8T7dcOu8=";
  };

  dependencies = [
    cffi
    pycparser
    numpy
  ];

  meta = with lib; {
    homepage = "https://fy.chalmers.se/subatom/wigxjpf/";
    changelog = "https://fy.chalmers.se/subatom/wigxjpf/CHANGELOG";
    description = "WIGXJPF evaluates Wigner 3j, 6j and 9j symbols accurately using prime factorisation and multi-word integer arithmetic.";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
