{
  stdenv,
  lib,
  makeBinaryWrapper,
  fetchzip,
  unzip,
  ffmpeg,
  mkvtoolnix,
  tesseract,
  handbrake,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tdarr-node";
  version = "2.45.01";
  src = fetchzip {
    # Urls can be found here https://storage.tdarr.io/versions.json
    url = "https://storage.tdarr.io/versions/${finalAttrs.version}/linux_x64/Tdarr_Node.zip";
    hash = "";
  };

  buildInputs = [
  ];

  nativeBuildInputs = [
    unzip
    makeBinaryWrapper
  ];

  # unpackPhase = ''
  #   unzip $src
  # '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r ./ $out
    mkdir $out/bin
    makeBinaryWrapper $out/${finalAttrs.meta.mainProgram} $out/bin/${finalAttrs.meta.mainProgram} \
      --set ffmpegPath ${ffmpeg}/bin/ffmpeg \
      --set handbrakePath ${handbrake}/bin/HandBrakeCLI \
      --set mkvpropeditPath ${mkvtoolnix}/bin/mkvpropedit \
      --set ffprobePath ${ffmpeg}/bin/ffprobe \
      --set rootDataPath "/var/lib/tdarr"
  '';

  meta = with lib; {
    mainProgram = "Tdarr_Node";
    description = "Distributed transcode automation";
    homepage = "https://tdarr.io";
    license = licenses.unfree; # TODO: figure out if license is redistributable
    platforms = [ "x86_64-linux" ];
    # maintainers = with maintainers; [ ];
  };
})
