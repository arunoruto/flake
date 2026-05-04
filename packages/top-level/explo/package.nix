{
  lib,
  buildGoModule,
  fetchFromGitHub,
  # versionCheckHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "explo";
  version = "0.11.5";

  src = fetchFromGitHub {
    owner = "LumePart";
    repo = "Explo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A3ikFH0/C/dat1pf7t1Gp6bfitmbPHK+RKVzqsLzjc0=";
  };

  vendorHash = "sha256-jTvxv0cyE/+BNkrajIj8E3xlftq+PCtGbmz+P3IuMFw=";

  postInstall = ''
    mv $out/bin/main $out/bin/explo
  '';

  # nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Spotify's \"Discover Weekly\" for self-hosted music systems";
    homepage = "https://github.com/LumePart/Explo/";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lilacious ];
    mainProgram = "explo";
  };
})
