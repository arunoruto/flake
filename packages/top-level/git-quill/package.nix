{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "git-quill";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "arunoruto";
    repo = finalAttrs.pname;
    tag = "v${finalAttrs.version}";
    hash = "sha256-Tf/jUmlMYtETv/rcrLFBUKH0H0pezVBRP6rqi0LIfDk=";
  };

  vendorHash = "sha256-gAi4a3ZrmImd3m9TX0Te0PhVlwRiRqVV8+vdsyzdflg=";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/arunoruto/git-quill";
    changelog = "${finalAttrs.meta.homepage}/releases/tag/v${finalAttrs.version}";
    description = "AI autocomplete for your git commit/tag messages";
    maintainers = with lib.maintainers; [ arunoruto ];
    license = lib.licenses.mit;
  };
})
