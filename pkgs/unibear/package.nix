{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  deno,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "unibear";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "kamilmac";
    repo = "unibear";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ATySOd/oqmImLtSO/Am4LahEqbj91ns0ZZxRmpOUpD4=";
  };

  buildInputs = [ deno ];

  # dontStrip = true;

  postUnpack = ''
    deno cache src/main.ts 
  '';

  buildPhase = ''
    deno compile -A -o unibear src/main.ts
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 -t $out/bin unibear
  '';

  passthru = {
    updateScript = nix-update-script { };
    # tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
  };

  meta = {
    description = "A lean TUI AI assistant: run your tools, stay in control, no magic tricks.";
    homepage = "https://github.com/kamilmac/unibear";
    license = lib.licenses.mit;
    mainProgram = finalAttrs.name;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with lib.maintainers; [ arunoruto ];
  };
})
