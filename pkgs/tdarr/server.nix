{
  stdenv,
  lib,
  makeBinaryWrapper,
  fetchzip,
  ffmpeg,
  mkvtoolnix,
  tesseract,
  handbrake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tdarr-server";
  version = "2.45.01";
  src = fetchzip {
    # Urls can be found here https://storage.tdarr.io/versions.json
    url = "https://storage.tdarr.io/versions/${finalAttrs.version}/linux_x64/Tdarr_Server.zip";
    hash = "sha256-hUMIFB4Ep2JRBGyDuUuK2TOOxFPcVKl73vxya0MozdQ=";
    stripRoot = false;
  };

  buildInputs = [
    tesseract
  ];

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  patchPhase = ''
    # Remove bundled ffmpeg, since we will be using the one from nixpkgs
    rm -rf ./node_modules/ffmpeg-static/ffmpeg
    # rm -rf ./node_modules/@ffprobe-installer/linux-x64/ffprobe
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r ./ $out
    makeBinaryWrapper $out/${finalAttrs.meta.mainProgram} $out/bin/${finalAttrs.meta.mainProgram} \
      --set ffmpegPath ${ffmpeg}/bin/ffmpeg \
      --set handbrakePath ${handbrake}/bin/HandBrakeCLI \
      --set mkvpropeditPath ${mkvtoolnix}/bin/mkvpropedit \
      --set ffprobePath ${ffmpeg}/bin/ffprobe \
      --set rootDataPath "/var/lib/tdarr"
  '';

  meta = with lib; {
    mainProgram = "Tdarr_Server";
    description = "Distributed transcode automation";
    homepage = "https://tdarr.io";
    license = licenses.unfree; # TODO: figure out if license is redistributable
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
})
