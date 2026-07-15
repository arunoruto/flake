{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
  # nix-update-script,
  unstableGitUpdater,
}:

buildGoModule (finalAttrs: {
  pname = "mayberry";
  version = "0-unstable-2026-07-13";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "SoFriendly";
    repo = "mayberry-branch";
    # tag = "v${finalAttrs.version}";
    rev = "b75a26e3b48467605178aff4dff30fb3605c4cf7";
    hash = "sha256-5nv2pbm8g/JCPRUnpO4c7nrYAN6hrWsSejgWROc8zoM=";
  };

  vendorHash = "sha256-oe5njWVW7EEvxTY+HlNGqXr4ZYQ8KZDP4H3dzItUE3s=";

  ldflags = [
    "-X main.Version=${finalAttrs.version}"
  ];

  # preBuild = ''
  #   mkdir -p src/web/dist
  #   cp -r ${finalAttrs.webui}/* src/web/dist
  # '';

  postInstall = ''
    mv $out/bin/branch $out/bin/mayberry
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";
  doInstallCheck = true;

  # passthru.updateScript = nix-update-script { };
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = " A federated library branch daemon";
    homepage = "https://joinmayberry.com/";
    # changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    mainProgram = "mayberry";
  };
})
