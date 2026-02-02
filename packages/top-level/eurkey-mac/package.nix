{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "eurkey-mac";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "jonasdiemer";
    repo = "EurKEY-Mac";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/Tmm9dkE1HILryzQ9e6or+Z9geCzS5yZ8GLN3ak22pU=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/eurkey
    cp EurKEY.keylayout $out/share/eurkey/
    cp EurKEY.icns $out/share/eurkey/

    runHook postInstall
  '';

  meta = {
    description = "The European Keyboard Layout for macOS";
    longDescription = ''
      EurKEY is a keyboard layout for Europeans, coders and translators.
      It features a US QWERTY baseline layout with quick access to commonly
      used accented characters and umlauts via AltGr (Right Option) key.
    '';
    homepage = "https://eurkey.steffen.bruentjen.eu/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.darwin;
    maintainers = [ ];
  };
})
