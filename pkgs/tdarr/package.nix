{ stdenv, fetchzip }:
stdenv.mkDerivation (finalAttrs: {
  pname = "tdarr";
  version = "2.17.01";

  # src = fetchzip {
  #   url = "https://storage.tdarr.io/versions/${finalAttrs.version}/linux_x64/Tdarr_Updater.zip";
  #   hash = "";
  #   # stripRoot = false;
  # };
  srcs = [
    (fetchzip {
      name = "server";
      url = "https://storage.tdarr.io/versions/${finalAttrs.version}/linux_x64/Tdarr_Server.zip";
      hash = "sha256-LpF7iB9gdWPQtBakHCko0z6uFWsh1Ljdtc1iyaFGplU=";
      stripRoot = false;
    })
    (fetchzip {
      name = "node";
      url = "https://storage.tdarr.io/versions/${finalAttrs.version}/linux_x64/Tdarr_Node.zip";
      hash = "sha256-TYXF/9R5zykNnfGZ2JW0XiuXWHQbvLDsxfujha+CYgg=";
      stripRoot = false;
    })
  ];
  sourceRoot = ".";
  installPhase = ''
    # runHook preUnpack

    sources=($srcs)

    mkdir -p $out/{server,node}
    cp -r ''${sources[0]}/* $out/server
    cp -r ''${sources[1]}/* $out/node

    # runHook postUnpack
  '';
})
