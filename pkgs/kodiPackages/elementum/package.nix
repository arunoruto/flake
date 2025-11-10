{
  lib,
  kodiPackages,
  buildKodiAddon,
  fetchFromGitHub,
  python3Packages,
  stdenv,
  autoPatchelfHook,
}:
let
  arch =
    {
      aarch64-linux = "arm64";
      x86_64-darwin = "x64";
      x86_64-linux = "x64";
    }
    ."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  os =
    {
      aarch64-linux = "linux";
      x86_64-darwin = "darwin";
      x86_64-linux = "linux";
    }
    ."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
# kodiPackages.buildKodiAddon rec {
buildKodiAddon rec {
  pname = "elementum";
  namespace = "plugin.video.elementum";
  version = "0.1.109";

  src = fetchFromGitHub {
    owner = "elgatito";
    repo = namespace;
    tag = "v${version}";
    hash = "sha256-ZxvmRAMCKrorxnB0UqyYw7EgDlFHnNo/muREfu01sOU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  propagatedBuildInputs =
    # [ flake8 ]
    # ++
    with python3Packages; [
      flake8
      six
      requests
    ];

  buildPhase = ":";

  postInstall = ''
    rm -r $out/share/kodi/addons/plugin.video.elementum/resources/bin/*
    cp -r $src/resources/bin/${os}_${arch} $out/share/kodi/addons/plugin.video.elementum/resources/bin/
  '';

  passthru = {
    pythonPath = "resources/site-packages";
  };

  meta = with lib; {
    homepage = "https://github.com/elgatito/plugin.video.elementum";
    description = "Torrent finding and streaming engine for KODi";
    license = licenses.mit;
    maintainers = teams.kodi.members ++ [ maintainers.arunoruto ];
  };
}
