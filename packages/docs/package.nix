{
  lib,
  stdenvNoCC,
  mdbook,
}:
stdenvNoCC.mkDerivation {
  pname = "flake-docs";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./../..;
    fileset = (lib.fileset.maybeMissing ./../../docs);
  };

  nativeBuildInputs = [ mdbook ];

  buildPhase = ''
    runHook preBuild
    cd docs && mdbook build --dest-dir $out
    runHook postBuild
  '';

  dontInstall = true;

  meta = {
    description = "Documentation for the flake configuration";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = lib.platforms.all;
  };
}
