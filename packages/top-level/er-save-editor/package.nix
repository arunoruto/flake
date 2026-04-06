{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "er-save-editor";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ClayAmore";
    repo = "ER-Save-Editor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4qNIN7Spm4hky642aejzbd7ltuyYTNXyLTPiqo90hH0=";
  };

  cargoHash = "sha256-+g3JpaKb/h0PJNoMzlQAHofph/ToxH5vm7v4uvO/q4Q=";

  # cargoBuildFlags = [
  #   "--package"
  #   "me3-cli"
  # ];
  # cargoTestFlags = [
  #   "--package"
  #   "me3-cli"
  # ];

  meta = {
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/tag/v${finalAttrs.version}";
    description = "Elden Ring Save Editor. Compatible with PC and Playstation saves.";
    maintainers = with lib.maintainers; [ arunoruto ];
    license = lib.licenses.asl20;
  };
})
