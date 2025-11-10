{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  dotnet-sdk,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fileflow";
  version = "25.6.9.5574";

  src = fetchzip {
    url = "https://fileflows.com/downloads/Zip/${finalAttrs.version}";
    hash = "sha256-ah5WT0FDZzKdouDhSEdnjKzRO2rZUKkxtoSQ4NLpMlk=";
    extension = "zip";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    dotnet-sdk
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r ./* $out/


    makeWrapper "${dotnet-sdk}/bin/dotnet" $out/bin/fileflows-server-gui \
      --add-flags "$out/Server/FileFlows.Server.dll --gui" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ ]}

    runHook postInstall
  '';

  # installPhase = ''
  #   runHook preInstall

  #   mkdir -p $out/{bin,share/${finalAttrs.pname}-${finalAttrs.version}}
  #   cp -r * $out/share/${finalAttrs.pname}-${finalAttrs.version}/.

  #   makeWrapper "${dotnet-runtime}/bin/dotnet" $out/bin/Radarr \
  #     --add-flags "$out/share/${finalAttrs.pname}-${finalAttrs.version}/Radarr.dll" \
  #     --prefix LD_LIBRARY_PATH : ${
  #       lib.makeLibraryPath [
  #         curl
  #         sqlite
  #         libmediainfo
  #         mono
  #         openssl
  #         icu
  #         zlib
  #       ]
  #     }

  #   runHook postInstall
  # '';

  meta = with lib; {
    description = "Automatically process files like videos, audio, books, texts, etc.";
    homepage = "https://fileflows.com/";
    changelog = "https://fileflows.com/news";
    license = licenses.unfree;
    # maintainers = with maintainers; [ ];
    # mainProgram = "Radarr";
    # platforms = [
    #   "x86_64-linux"
    #   "aarch64-linux"
    #   "x86_64-darwin"
    #   "aarch64-darwin"
    # ];
  };
})
