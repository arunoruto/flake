{
  lib,
  stdenv,
  makeWrapper,

  # runtime
  xercesc,
}:
let
  pname = "isis";
  version = "8.3.0";

in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = builtins.fetchTarball {
    url = "https://anaconda.org/usgs-astrogeology/${pname}/${version}/download/linux-64/${pname}-${version}-0.tar.bz2";
    sha256 = "sha256:0b0wlb9z9p5liws38bhbjvjpb2603355bwbkgv5x81p7pyf4wkdi";
  };

  buildInputs = [
    xercesc
  ];

  nativeBuildInputs = [
    # conda
    # xercesc
    makeWrapper
  ];

  buildPhase = ''

  '';

  installPhase = ''
    # runHook preInstall

    mkdir -p $out
    cp -r . $out
    # gtk-update-icon-cache $out/share/icons/candy-icons

    runHook postInstall
  '';

  postInstallPhase = ''
    patchelf --set-rpath "${lib.makeLibraryPath [ xercesc ]}" $out/bin/isis2ascii
  '';

  # extraWrapProgramArgs = ''
  #   --prefix LD_LIBRARY_PATH : $out/lib : ${lib.makeLibraryPath [ xercesc ]}
  # '';

  meta = with lib; {
    homepage = "https://isis.astrogeology.usgs.gov";
    description = "A digital image processing software package to manipulate imagery collected by current and past NASA and International planetary missions";
    license = licenses.cc0;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
