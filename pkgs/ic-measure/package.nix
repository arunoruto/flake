{
  lib,
  appimageTools,
  fetchzip,
}:

let
  pname = "ic-measure";
  version = "3.0.0.503";

  src = fetchzip {
    url = "https://dl.theimagingsource.com/5561fc6f-d2a3-5b24-82bc-b06c7f80c463/";
    hash = "";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  # extraInstallCommands = ''
  #   substituteInPlace $out/share/applications/${pname}.desktop \
  #     --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
  # '';

  meta = {
    description = "";
    homepage = "https://www.theimagingsource.com/";
    downloadPage = "https://www.theimagingsource.com/de-de/support/download/icmeasureappimage-${builtins.toString version}/";
    # license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = [ "x86_64-linux" ];
  };
}
