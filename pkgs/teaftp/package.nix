{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
let
  pname = "teaftp";
  version = "1.3.1";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-kY7l/YZLQXw9aQzTwGmLPi9WA5rhaNc5zZjBT/7UQkk=";
  };

  vendorHash = null;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    description = "Simple, read-only TFTP server: serve files simply from the terminal";
    homepage = "https://github.com/xyproto/teaftp";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ arunoruto ];
  };
}
# buildGoModule (finalAttrs: {
#   pname = "teaftp";
#   version = "1.3.1";

#   src = fetchFromGitHub {
#     owner = "xyproto";
#     repo = "teaftp";
#     tag = "v${finalAttrs.version}";
#     hash = "";
#   };

#   vendorHash = "";

#   meta = {
#     description = "Simple, read-only TFTP server: serve files simply from the terminal";
#     homepage = "https://github.com/xyproto/teaftp";
#     license = lib.licenses.bsd3;
#     maintainers = with lib.maintainers; [ arunoruto ];
#   };
# })
