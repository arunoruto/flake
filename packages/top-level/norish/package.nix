{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_12,
  nodejs_26,
  python3,
  yt-dlp,
  ffmpeg-headless,
  makeWrapper,
  autoPatchelfHook,
  nix-update-script,
}:
let
  # ponytail: nixpkgs' Python and libraries instead of the uv.lock pins
  # (recipe-scrapers, fastapi lag by a few releases); pin them via overrides if
  # a scraper breaks.
  parserPython = python3.withPackages (
    ps: with ps; [
      beautifulsoup4
      fastapi
      recipe-scrapers
      uvicorn
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "norish";
  version = "0.26.0-beta";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "norish-recipes";
    repo = "norish";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SzG1BcH0GmEFDcNMBw8kdUCjLhuq2bpGauyXlYfmisY=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_12;
    fetcherVersion = 5;
    hash = "sha256-p3YdVunecVGb3+cgTQ/y+uh3KmR1lcy+8bRNBZ3fz3M=";
  };

  nativeBuildInputs = [
    pnpm_12
    pnpmConfigHook
    nodejs_26
    makeWrapper
    autoPatchelfHook
  ];

  # Prebuilt native addons in node_modules (sharp, ...) link libstdc++.
  buildInputs = [ stdenv.cc.cc.lib ];

  env = {
    NEXT_TELEMETRY_DISABLED = "1";
    NODE_ENV = "production";
    SKIP_ENV_VALIDATION = "1";
    DATABASE_URL = "postgresql://dummy:dummy@localhost:5432/dummy";
    # @swc/core unpacks its addon into a cache whose ancestors must not be
    # writable by another user, which the sandbox's / fails.
    SWC_NATIVE_BINDING_CACHE_SKIP_SECURITY_CHECK = "1";
  };

  buildPhase = ''
    runHook preBuild
    export SWC_NATIVE_BINDING_CACHE="$(mktemp -d)"
    export NORISH_VERSION_REPORT_JSON="$(node tooling/monorepo/scripts/print-package-versions.mjs)"
    pnpm --filter "@norish/web..." run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    rm -rf apps/web/.next/cache apps/web/.next/trace apps/web/.next/dev \
      apps/docs apps/mobile apps/landing apps/quick-import-extension \
      node_modules/.pnpm/node_modules/@norish/landing
    # tsx would apply apps/web's @norish/queue/* path alias and load a second
    # queue registry (see upstream's docker/Dockerfile).
    rm apps/web/tsconfig.json

    # The server spawns <parser>/.venv/bin/python -m uvicorn.
    mkdir -p apps/parser-api/.venv/bin bin
    ln -s ${lib.getExe parserPython} apps/parser-api/.venv/bin/python
    # In production the server expects yt-dlp in YT_DLP_BIN_DIR and never downloads it.
    ln -s ${lib.getExe yt-dlp} bin/yt-dlp

    mkdir -p $out/share
    cp -r . $out/share/norish

    makeWrapper ${lib.getExe nodejs_26} $out/bin/norish \
      --chdir $out/share/norish/apps/web \
      --add-flags "--import tsx server/index.ts" \
      --set-default NODE_ENV production \
      --set-default NEXT_TELEMETRY_DISABLED 1 \
      --set-default YT_DLP_BIN_DIR $out/share/norish/bin \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg-headless ]}

    runHook postInstall
  '';

  # Every tag is named -beta; the releases' own pre-release flag says which count.
  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Self-hosted recipe manager that imports from sites, videos, photos and text";
    homepage = "https://norish.dev";
    changelog = "https://github.com/norish-recipes/norish/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ arunoruto ];
    mainProgram = "norish";
    platforms = lib.platforms.linux;
  };
})
