{
  stdenv,
  mkYarnPackage,
  lib,
  fetchFromGitHub,
  yarn,
  clickgen,
  zip,
}:
let
  pname = "banana-cursor";
  version = "v2.0.0";

  # src = fetchFromGitHub {
  #   owner = "ful1e5";
  #   repo = pname;
  #   rev = version;
  #   hash = "sha256-DSgc3y4T/mWO9KC6KBy5W7M8TMM0s4U4pnr/Zy3yTMM=";
  # };

  src = fetchFromGitHub {
    owner = "arunoruto";
    repo = pname;
    rev = "762dfa08b56c9fb4165cbd10568004fab9a1fd7c";
    hash = "sha256-CE0iL7I5qst3oFbTWVAeD7u1jRLgE4IX3zOjJvTgH0Y=";
  };

  yarn-env = mkYarnPackage {
    name = pname;
    src = "${src}";
    packageJSON = "${src}/package.json";
    yarnLock = "${src}/yarn.lock";

    buildPhase = ''
      # yarn --offline install
      yarn --offline generate
    '';
  };
in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = yarn-env;

  nativeBuildInputs = [
    yarn
    #   clickgen
    #   zip
  ];

  buildPhase = ''
    # yarn generate
    mkdir -p $out
    cp -r . $out
  '';

  # installPhase = ''
  #   mkdir -p $out/share/icons/${pname}
  #   cp ${pname} $out/share/icons/${pname}
  #   gtk-update-icon-cache $out/share/icons/${pname}
  # '';

  meta = with lib; {
    homepage = "https://github.com/ful1e5/banana-cursor";
    description = "The banana cursor. ";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
