{
  lib,
  stdenvNoCC,
  # fetchFromGitHub,
  conda,
}:
let
  pname = "isis";
  version = "8.3.0";

in
stdenvNoCC.mkDerivation {
  inherit pname;
  inherit version;

  # src = fetchFromGitHub {
  #   owner = "DOI-USGS";
  #   repo = pname;
  #   rev = version;
  #   hash = "sha256-84DuZhzwqdE1ZFv5ytg4XxveuHXacFelYC0ERlExLS4=";
  # };
  src = builtins.fetchTarball {
    url = "https://anaconda.org/usgs-astrogeology/${pname}/${version}/download/linux-64/${pname}-${version}-0.tar.bz2";
    sha256 = "sha256:0l910hqwrnd6c9zyc031x2iw1ji07amhs82g0c67lyxcj59nk1k7";
  };

  nativeBuildInputs = [
    conda
  ];

  buildPhase = ''

  '';

  installPhase = ''
    # runHook preInstall

    # mkdir -p $out/share/icons/candy-icons
    # cp -r . $out/share/icons/candy-icons
    # gtk-update-icon-cache $out/share/icons/candy-icons

    # runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://isis.astrogeology.usgs.gov";
    description = "A digital image processing software package to manipulate imagery collected by current and past NASA and International planetary missions";
    license = licenses.cc0;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
