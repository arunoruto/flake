{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # fetchPypi,

  # dependencies
  numba,
}:
let
  pname = "numba-cuda";
  version = "0.8.1";
in
buildPythonPackage {
  inherit pname version;
  format = "setuptools";
  src = fetchFromGitHub {
    owner = "nvidia";
    repo = pname;
    rev = "v" + version;
    hash = "sha256-txUgKv2rggj8FNCUet4ngpixb5jjPBqBytMcVYt85Dw=";
  };

  dependencies = [
    numba
  ];

  meta = with lib; {
    homepage = "https://nvidia.github.io/numba-cuda/";
    description = "The CUDA target for Numba ";
    license = licenses.bsd2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
