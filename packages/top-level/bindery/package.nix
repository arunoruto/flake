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
  version = "1.22.3";

  src = fetchFromGitHub {
    owner = "vavallee";
    repo = "bindery";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GXHWx0V4SZYB+h/7n4VOq2AA3lW0QW5gyZ33/GE9kho=";
  };

  vendorHash = "sha256-gWpHkJYJE7WO1ju2dsfDi8RYeZoFgyBuDQ/zIjUxLBg=";

  webui = buildNpmPackage {
    inherit (finalAttrs)
      pname
      version
      src
      ;

    sourceRoot = "${finalAttrs.src.name}/web";

    npmDepsHash = "sha256-TEcFXFCrmkzq883GUy4cEr0AUIaQGJR0X0+KXbFCsgI=";

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
    mainProgram = "bindery"; # Silences the versionCheckHook warning
  };
})
