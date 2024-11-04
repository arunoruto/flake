{
  lib,
  stdenv,
  autoPatchelfHook,

  # runtime
  geos,
  opencv,
  xercesc,
  qt5,
  libsForQt5,
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
    # sha256 = "sha256:1y2wh58vcnggwzblzcnrdbfbm78gb1d12bn6zgadjdggs6r472s0"; # 8.2.0
    sha256 = "sha256:0b0wlb9z9p5liws38bhbjvjpb2603355bwbkgv5x81p7pyf4wkdi"; # 8.3.0
  };

  buildInputs = [
    xercesc
  ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  autoPatchelfIgnoreMissingDeps = [
    # "libgeos.so.3.12.0"
    # "libopencv_core.so.407"
    # "libopencv_imgproc.so.407"
    # "libqwt.so.6.2"

    "libisis.so"
    "libapollo.so"
    "libcassini.so"
    "libchandrayaan1.so"
    "libclementine.so"
    "libclipper.so"
    "libcspice.so.67"
    "libdawn.so"
    "libgalileo.so"
    "libhayabusa.so"
    "libhayabusa2.so"
    "libkaguya.so"
    "liblo.so"
    "liblro.so"
    "libmer.so"
    "libmessenger.so"
    "libmex.so"
    "libmgs.so"
    "libmro.so"
    "libnear.so"
    "libnewhorizons.so"
    "libodyssey.so"
    "libosirisrex.so"
    "librosetta.so"
    "libtgo.so"
    "libviking.so"
  ];

  preBuild = ''
    addAutoPatchelfSearchPath ${qt5.qtbase}  ${libsForQt5.qwt}
  '';

  # buildPhase = ''

  # '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r . $out

    ln -s ${geos}/lib/libgeos.so $out/lib/libgeos.so.3.12.0
    ln -s ${opencv}/lib/libopencv_core.so $out/lib/libopencv_core.so.407
    ln -s ${opencv}/lib/libopencv_imgproc.so $out/lib/libopencv_imgproc.so.407

    # runHook postInstall
  '';

  # postFixup = ''
  #   runHook autoPatchelfHook --ignore-missing="libisis.so"
  # '';

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
