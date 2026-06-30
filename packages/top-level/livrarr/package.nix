{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  nodejs,
  makeWrapper,
  nix-update-script,
  tzdata,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "livrarr";
  version = "0.1.0-alpha5";

  src = fetchFromGitHub {
    owner = "kkodecs";
    repo = "livrarr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qoAvBEH4jPo4IoaGdNedDDhm3anKB5xxpLPuhJtAO+c=";
  };

  cargoHash = "sha256-TUpfsODbKOhxtPZEkEOTPjqLdGgpCr7NuvKxkWZYWUE=";

  cargoBuildFlags = [
    "--package"
    "livrarr-server"
  ];

  cargoTestFlags = [
    "--package"
    "livrarr-server"
  ];

  frontend = stdenv.mkDerivation (fa: {
    pname = "${finalAttrs.pname}-frontend";
    inherit (finalAttrs) version;
    src = stdenv.mkDerivation {
      name = "${finalAttrs.pname}-frontend-src";
      buildCommand = ''
        mkdir -p $out
        cp -r ${finalAttrs.src}/frontend/* $out/
      '';
    };

    nativeBuildInputs = [
      pnpm
      pnpmConfigHook
      nodejs
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (fa) pname version src;
      fetcherVersion = 3;
      hash = "sha256-Fhjf8m3CnmHxDvYUN7VKPHocfETE6721eaHewzC9Rb8=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist $out/dist
      runHook postInstall
    '';
  });

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ tzdata ];

  postInstall = ''
    mkdir -p $out/share/livrarr
    cp -r ${finalAttrs.frontend}/dist $out/share/livrarr/ui
    wrapProgram $out/bin/livrarr \
      --add-flags "--ui-dir $out/share/livrarr/ui"
  '';

  updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/tag/v${finalAttrs.version}";
    description = "Self-hosted ebook and audiobook library manager";
    maintainers = with lib.maintainers; [ arunoruto ];
    license = lib.licenses.gpl3;
    mainProgram = "livrarr";
    platforms = lib.platforms.unix;
  };
})
