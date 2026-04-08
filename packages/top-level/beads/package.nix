{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  icu,
  gitMinimal,
  installShellFiles,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "beads";
  version = "0.63.2";

  src = fetchFromGitHub {
    owner = "steveyegge";
    repo = "beads";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ERRw+SgRgFzY+cchRRsCYUtKCXvRZOdWJuSAQPDVF3M=";
  };

  vendorHash = "sha256-GYPfvsI8eNJbdzrbO7YnMkN2Yt6KZNB7w/2SJD2WdFY=";

  subPackages = [ "cmd/bd" ];

  ldflags = [
    "-s"
    "-w"
  ];

  buildInputs = [ icu ];

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];

  checkFlags = [
    "-skip=TestE2E_AutoStartedRepoLocalServerPersistsAcrossCommands"
  ];

  preCheck = ''
    export PATH="$out/bin:$PATH"
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd bd \
      --bash <($out/bin/bd completion bash) \
      --fish <($out/bin/bd completion fish) \
      --zsh <($out/bin/bd completion zsh)
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  versionCheckProgramArg = "version";
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight memory system for AI coding agents with graph-based issue tracking";
    homepage = "https://github.com/steveyegge/beads";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      kedry
      arunoruto
    ];
    mainProgram = "bd";
    platforms = lib.platforms.unix;
  };
})
