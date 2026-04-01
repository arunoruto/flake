{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "me3";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "garyttierney";
    repo = "me3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XyeMVPGzNF2syipLz9HPtUg7lhxcEq434FnRH3Ax+HM=";
  };

  cargoHash = "sha256-T1HeYe9FUC5oy/SDeEd6vV4D9YIGIXMkbzf43gRNyt8=";

  cargoBuildFlags = [
    "--package"
    "me3-cli"
  ];
  cargoTestFlags = [
    "--package"
    "me3-cli"
  ];

  meta = {
    homepage = "https://me3.help";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/tag/v${finalAttrs.version}";
    description = "Framework for modding and instrumenting games";
    maintainers = with lib.maintainers; [ arunoruto ];
    license = lib.licenses.asl20;
  };
})
