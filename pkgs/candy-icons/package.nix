{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
}:
stdenvNoCC.mkDerivation {
  pname = "candy-icons";
  version = "unstable-2024-10-10";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "candy-icons";
    rev = "011363a8e2bceaef7d9c6e982eb20152c6676ca9";
    hash = "sha256-duhMByJzLV0nM7byvpdg1Z1Uw59OEaZ96UezTyfuXzg=";
  };

  nativeBuildInputs = [
    gtk3
  ];

  dontDropIconThemeCache = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons/candy-icons
    cp -r . $out/share/icons/candy-icons
    gtk-update-icon-cache $out/share/icons/candy-icons

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/EliverLara/candy-icons";
    description = "Icon theme colored with sweet gradients";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [arunoruto];
  };
}
