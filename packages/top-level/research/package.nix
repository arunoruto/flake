{
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,

  dbus,
  openssl,
  webkitgtk_4_1,
  gtk3,
  glib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "research";
  version = "1.0.0";
  src = fetchurl {
    url = "https://un.ms/research/downloads/${finalAttrs.version}/Research_${finalAttrs.version}_amd64.deb";
    hash = "sha256-lRcK2JUKzYVf/OQVGAk0cLqmACMl+SUCCKiTvueuy6M=";
  };
  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];
  buildInputs = [
    dbus.lib
    openssl.dev
    webkitgtk_4_1.dev
    gtk3.dev
    glib.dev
  ];

  installPhase = ''
    mkdir $out
    cp -r . $out
  '';
})
