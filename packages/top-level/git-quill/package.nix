{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "git-quill";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "arunoruto";
    repo = finalAttrs.pname;
    tag = "v${finalAttrs.version}";
    hash = "sha256-9clA+DqNMXHXbcsn2Me7et0U1YhUra1jQBRWBQP73Lw=";
  };

  vendorHash = "sha256-gAi4a3ZrmImd3m9TX0Te0PhVlwRiRqVV8+vdsyzdflg=";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  meta = {
    homepage = "https://github.com/arunoruto/git-quill";
    changelog = "${finalAttrs.meta.homepage}/releases/tag/v${finalAttrs.version}";
    description = "AI autocomplete for your git commit/tag messages";
    maintainers = with lib.maintainers; [ arunoruto ];
    license = lib.licenses.mit;
  };
})
