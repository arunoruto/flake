{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "bindery";
  version = "1.23.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "vavallee";
    repo = "bindery";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yrGOrSVJlrwEgi7KcrjJhmk4VrXzVtnE+cHgWngSQSM=";
  };

  vendorHash = "sha256-cpwLh/JR0KFTQcglp7kn9Zaf6dJ+RlQ9Kdembub8q/s=";

  webui = buildNpmPackage {
    inherit (finalAttrs)
      pname
      version
      src
      ;

    sourceRoot = "${finalAttrs.src.name}/web";

    npmDepsHash = "sha256-yf9X5DVQSpl6zZf+nYl2XOGbiO9RX36VP4dxsZ4IrV0=";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/* $out

      runHook postInstall
    '';
  };

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];
  subpackages = [ "cmd/bindery" ];
  excludedPackages = [
    "tests/canary"
    "internal/api"
  ];

  postPatch = ''
    cat << 'EOF' > cmd/bindery/nix_version_check.go
    package main

    import (
        "fmt"
        "os"
    )

    func init() {
        if len(os.Args) > 1 && (os.Args[1] == "--version" || os.Args[1] == "-v") {
            fmt.Println(version)
            os.Exit(0)
        }
    }
    EOF
  '';

  preBuild = ''
    mkdir -p internal/webui/dist
    cp -r ${finalAttrs.webui}/* internal/webui/dist
  '';

  checkFlags = [ "-v" ];

  nativeBuildInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "webui"
      ];
    };
  };

  meta = {
    homepage = "https://github.com/vavallee/bindery";
    changelog = "${finalAttrs.meta.homepage}/releases/tag/v${finalAttrs.version}";
    description = "Automated book download manager for Usenet";
    maintainers = with lib.maintainers; [ arunoruto ];
    license = lib.licenses.mit;
    mainProgram = "bindery";
  };
})
