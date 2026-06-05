{
  lib,
  fetchFromGitHub,
  buildGoModule,
  # versionCheckHook,
  # writableTmpDirAsHomeHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "gh-pr-review";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "agynio";
    repo = "gh-pr-review";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NVctUkxfYGs29T9naAfqbEhUXfhynx8Ajsh+V+4gCLw=";
  };

  vendorHash = "sha256-CEV23koYz0FpSWXJRF4J+dGNuDT8Ftkn4LGFftvd0ts=";

  # ldflags = [
  #   "-s"
  #   "-w"
  #   "-X github.com/agynio/gh-pr-review/v4/cmd.Version=${finalAttrs.version}"
  # ];

  # checkFlags = [
  #   # requires network
  #   "-skip=TestFullOutput"
  # ];

  # nativeCheckInputs = [ writableTmpDirAsHomeHook ];
  # nativeInstallCheckInputs = [ versionCheckHook ];
  # doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/agynio/gh-pr-review";
    changelog = "https://github.com/agynio/gh-pr-review/releases/tag/${finalAttrs.src.rev}";
    description = "GitHub CLI extension that adds full inline PR review comment support ";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    mainProgram = "gh-pr-review";
  };
})
