{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
let
  pname = "teaftp";
  version = "1.3.2";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-7KE1BiBRXcHfPm1KbGJn6/VVWGMA+FQ5sbL3k2NVv68=";
    # hash = "sha256-kY7l/YZLQXw9aQzTwGmLPi9WA5rhaNc5zZjBT/7UQkk="; # 1.3.1
    # hash = "sha256-Xdx2DAwXK/nhIkF8GFKjjA7oYpj0L8yZ2e+ByYpUU4M="; # 1.3.0
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
