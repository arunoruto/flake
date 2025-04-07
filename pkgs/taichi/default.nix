{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  scikit-build,
}:
let
  finalAttrs = {
    pname = "taichi";
    version = "1.7.3";
  };
in
buildPythonPackage {
  inherit (finalAttrs) pname version;
  # format = "setuptools";
  src = fetchFromGitHub {
    owner = "taichi-dev";
    repo = finalAttrs.pname;
    tag = "v${finalAttrs.version}";
    hash = "sha256-QWtxPgR8RGnIEpbGO18Y8TFNhbKd4pOi9VLEkK2nhfk=";
    fetchSubmodules = true;
    # leaveDotGit = true;
  };

  nativeBuildInputs = [
    scikit-build
  ];

  buildPhase = ''
    ls -la
    cat ./build.py
    $src/build.py --shell
  '';
}
