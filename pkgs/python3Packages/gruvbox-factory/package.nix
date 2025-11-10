{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchFromGitHub,

  # dependencies
  rich,
  image-go-nord,
}:
let
  pname = "gruvbox-factory";
  version = "1.1.0";
in
buildPythonPackage {
  inherit pname version;
  format = "setuptools";
  src = fetchFromGitHub {
    # inherit pname version;
    # extension = "tar.gz";
    owner = "paulopacitti";
    repo = pname;
    rev = "v" + version;
    hash = "sha256-p1kVIUCgzCmWV1bJTWKWKqzw2aPOJy+a+5rl3dfiWTg=";
  };

  dependencies = [
    rich
    image-go-nord
  ];

  meta = with lib; {
    homepage = "https://github.com/paulopacitti/gruvbox-factory";
    description = "🏭 convert any image to the gruvbox pallete";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
