{
  lib,
  stdenvNoCC,
  mdbook,
  docs-devix-reference,
  docs-steamix-reference,
}:
stdenvNoCC.mkDerivation {
  pname = "flake-docs";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./../..;
    # docs/steamix is a symlink into steamix/docs (the pages belong to the
    # in-repo Steamix flake); both sides have to be in the source for it to
    # resolve inside the sandbox.
    fileset = lib.fileset.unions [
      (lib.fileset.maybeMissing ./../../docs)
      (lib.fileset.maybeMissing ./../../steamix/docs)
    ];
  };

  nativeBuildInputs = [ mdbook ];

  buildPhase = ''
    runHook preBuild

    # docs/devix/reference and docs/steamix/reference are generated from the
    # option descriptions in their modules, so they are not part of the source
    # tree (see .gitignore). `just docs` drops the same files in place for
    # local previews.
    mkdir -p docs/devix/reference docs/steamix/reference
    cp ${docs-devix-reference}/*.md docs/devix/reference/
    cp ${docs-steamix-reference}/*.md docs/steamix/reference/

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
