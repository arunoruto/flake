{
  lib,
  buildKodiAddon,
  fetchFromGitHub,
  flake8,
# requests,
# inputstream-adaptive,
# inputstreamhelper,
}:
buildKodiAddon rec {
  pname = "elementum";
  namespace = "plugin.video.elementum ";
  version = "0.1.109";

  src = fetchFromGitHub {
    owner = "elgatito";
    repo = namespace;
    rev = "v${version}";
    hash = "";
  };

  propagatedBuildInputs = [
    flake8
    # requests
    # inputstream-adaptive
    # inputstreamhelper
  ];

  # passthru = {
  #   pythonPath = "resources/lib";
  # };

  meta = with lib; {
    homepage = "https://github.com/elgatito/plugin.video.elementum";
    description = "Torrent finding and streaming engine for KODi";
    license = licenses.mit;
    maintainers = teams.kodi.members ++ [ maintainers.arunoruto ];
  };
}
