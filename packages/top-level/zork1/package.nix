{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  frotz,

  zork ? "zork1",
  hash ? "sha256-bEKPFaQalSqRsVqWueWg9uHGbM7H1NLgks8BaYAdkcw=",
}:
stdenv.mkDerivation (finalAttrs: {
  pname = zork;
  version = "0-unstable-2000-12-20";

  src = fetchzip {
    url = "http://infocom.elsewhere.org/scheyen/Download/${finalAttrs.pname}.zip";
    inherit hash;
    # hash = "sha256-bEKPFaQalSqRsVqWueWg9uHGbM7H1NLgks8BaYAdkcw=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ frotz ];

  preInstall = ''
    mkdir -p $out/usr/share/zork
    mkdir -p $out/bin
    cat >> $out/bin/${finalAttrs.pname} << EOF
    #!/usr/bin/env bash
    frotz $out/usr/share/zork/${finalAttrs.pname}/${lib.strings.toUpper finalAttrs.pname}.DAT
    EOF
    chmod +x $out/bin/${finalAttrs.pname}
  '';

  installPhase = ''
    runHook preInstall

    install -D -m644 DATA/${lib.strings.toUpper finalAttrs.pname}.DAT $out/usr/share/zork/${finalAttrs.pname}/${lib.strings.toUpper finalAttrs.pname}.DAT
    # install -D -m644 legend.gif $out/usr/share/zork/${finalAttrs.pname}/maps/legend.gif
    # install -m644 *.gif $out/usr/share/zork/${finalAttrs.pname}/maps/
    # install -D -m755 ${finalAttrs.pname} $out/usr/bin/${finalAttrs.pname}
    # install -D -m644 LICENSE $out/usr/share/licenses/${finalAttrs.pname}/LICENSE

    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/${finalAttrs.pname} \
      --prefix PATH : ${lib.makeBinPath [ frotz ]}
  '';

  meta = {
    homepage = "http://www.infocom-if.org/";
    description = "${finalAttrs.pname} adventure game (for Infocom's z-code interpreter)";
    maintainers = with lib.maintainers; [ arunoruto ];
    licence = lib.licenses.unfree;
    mainProgram = finalAttrs.pname;
    # license = {
    #   deprecated = false;
    #   free = false;
    #   redistributable = false;
    #   fullName = "Zork Licence";
    #   shortName = "Zork Licence";
    #   url = "https://github.com/customer-terms/github-copilot-product-specific-terms";
    # };
  };
})
