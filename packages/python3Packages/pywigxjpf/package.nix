{
  lib,
  buildPythonPackage,

  # wigxjpf,

  setuptools,
  wheel,

  numpy,
  cffi,
}:

buildPythonPackage rec {
  pname = "pywigxjpf";
  version = "1.13";

  # inherit (wigxjpf) src;
  src = builtins.fetchurl {
    url = "http://fy.chalmers.se/subatom/wigxjpf/wigxjpf-${version}.tar.gz";
    hash = "sha256-kKub/UlZeK0f3LtDbidNb0WGGErikLmZIOXJeNZLPmo=";
  };

  pyproject = true;

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    numpy
    cffi
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="-fPIC $NIX_CFLAGS_COMPILE"
    make -j$NIX_BUILD_CORES
    make pywigxjpf_ffi
  '';

  doCheck = false;

  pythonImportsCheck = [ "pywigxjpf" ];

  meta = with lib; {
    homepage = "https://fy.chalmers.se/subatom/wigxjpf/";
    changelog = "https://fy.chalmers.se/subatom/wigxjpf/CHANGELOG";
    description = "WIGXJPF evaluates Wigner 3j, 6j and 9j symbols accurately using prime factorisation and multi-word integer arithmetic.";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
