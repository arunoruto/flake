{
  lib,
  stdenvNoCC,
  mdbook,
  docs-devix-reference,
  docs-steamos-reference,
}:
stdenvNoCC.mkDerivation {
  pname = "flake-docs";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./../..;
    fileset = lib.fileset.maybeMissing ./../../docs;
  };

  nativeBuildInputs = [ mdbook ];

  buildPhase = ''
    runHook preBuild

    # docs/devix/reference and docs/steamos/reference are generated from the
    # option descriptions in their modules, so they are not part of the source
    # tree (see .gitignore). `just docs` drops the same files in place for
    # local previews.
    mkdir -p docs/devix/reference docs/steamos/reference
    cp ${docs-devix-reference}/*.md docs/devix/reference/
    cp ${docs-steamos-reference}/*.md docs/steamos/reference/

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
