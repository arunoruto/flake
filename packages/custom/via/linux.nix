{
  lib,
  appimageTools,
}:

{
  pname,
  version,
  src,
  meta,
  __structuredAttrs ? true,
  strictDeps ? true,
}:

let
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
# wrapType2 forwards anything it does not consume itself down to buildFHSEnv.
appimageTools.wrapType2 {
  inherit
    pname
    version
    src
    meta
    __structuredAttrs
    strictDeps
    ;

  profile = ''
    export DISABLE_SUDO_PROMPT=1
  '';

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/via-nativia.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/via-nativia.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share

    mkdir -p $out/etc/udev/rules.d
    echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"' > $out/etc/udev/rules.d/92-viia.rules
  '';
}
