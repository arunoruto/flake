{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
let
  pname = "tftp-now";
  version = "1.1.0";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "puhitaku";
    repo = pname;
    tag = "v${version}";
    hash = "";
  };

  vendorHash = null;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    description = "Single-binary TFTP server and client that you can use right now. No package installation, no configuration, no frustration. ";
    homepage = "https://github.com/puhitaku/tftp-now";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
  };
}
