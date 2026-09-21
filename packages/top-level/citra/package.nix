{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  versionCheckHook,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "citra";
  version = "4.1.3";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "SylphxAI";
    repo = "pdf-reader-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5x7uHuRG8+wN7jXtU+ojbph4wfApO8Q6NS2n0cMNqs0=";
  };

  cargoHash = "sha256-s/nCkpfitJN8fQxWMIYNNZlck3V3nWTL791Syf+uwXo=";

  nativeBuildInputs = [ makeWrapper ];

  # The parity test rebuilds pdf-reader-cli with cargo and expects it in
  # target/release; the nix build puts it under target/<triple>/release.
  checkFlags = [ "--skip=pdf_reader_cli_read_pdf_matches_core_golden_payload" ];

  # The server resolves its JSON engine CLI relative to a repo checkout, so
  # point it at the installed one. The npm distribution is only a node shim
  # that spawns this binary, so take over the bin names it declares.
  postInstall = ''
    wrapProgram $out/bin/pdf-reader-mcp-server \
      --set-default PDF_READER_CLI_BIN "$out/bin/pdf-reader-cli"

    ln -s pdf-reader-mcp-server $out/bin/citra
    ln -s pdf-reader-mcp-server $out/bin/pdf-reader-mcp
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "doctor";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "PDF evidence for agents: structured text, tables, OCR and page-level citations over MCP";
    homepage = "https://sylphxai.github.io/pdf-reader-mcp/";
    changelog = "https://github.com/SylphxAI/pdf-reader-mcp/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "citra";
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = lib.platforms.unix;
  };
})
