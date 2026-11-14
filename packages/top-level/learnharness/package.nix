# Built from source: `next build` (standalone output) curated by upstream's
# scripts/build-server.mjs, run under nixpkgs' Electron instead of the
# electron-builder bundle. Three deviations from the release build:
#   - next/font/google is swapped for the same two fonts from nixpkgs (the
#     build sandbox has no network);
#   - the shell finds the server next to itself instead of under
#     process.resourcesPath (there is no .app/Resources layout here);
#   - the browser-service helper is spawned with the app dir as argument,
#     since a bare nixpkgs electron binary has no embedded app.asar.
# electron-updater is not shipped: app.isPackaged is false here, so the shell
# skips the updater entirely (updates come from the flake).
{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  electron_44,
  jetbrains-mono,
  source-sans,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  autoPatchelfHook,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  __structuredAttrs = true;
  strictDeps = true;

  pname = "learnharness";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "amosblomqvist";
    repo = "learnharness";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hUhTUsblmdnkgD7DM6oEEQCFFNPoPUX1zotCgl+hKCY=";
  };

  npmDepsHash = "sha256-+OlIwC9UD7T15Z03IJjF2cNt9wk0/kqcBbviylWdRIA=";

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    autoPatchelfHook
  ];

  # The prebuilt napi binaries (resvg, @napi-rs/canvas) in the traced
  # standalone tree link against libstdc++.
  buildInputs = [ stdenv.cc.cc.lib ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    NEXT_TELEMETRY_DISABLED = "1";
  };

  appDir = "${placeholder "out"}/share/learnharness";

  postPatch = ''
    mkdir -p app/fonts
    cp '${jetbrains-mono}/share/fonts/truetype/JetBrainsMono[wght].ttf' app/fonts/jetbrains-mono.ttf
    cp ${source-sans}/share/fonts/truetype/SourceSans3VF-Upright.ttf app/fonts/source-sans-3.ttf
    substituteInPlace app/layout.tsx \
      --replace-fail 'import { JetBrains_Mono, Source_Sans_3 } from "next/font/google";' \
                     'import localFont from "next/font/local";' \
      --replace-fail 'JetBrains_Mono({ subsets: ["latin"], variable: "--font-jetbrains" })' \
                     'localFont({ src: "./fonts/jetbrains-mono.ttf", variable: "--font-jetbrains" })' \
      --replace-fail 'Source_Sans_3({ subsets: ["latin"], variable: "--font-sans3" })' \
                     'localFont({ src: "./fonts/source-sans-3.ttf", variable: "--font-sans3" })'

    substituteInPlace electron/main.cjs \
      --replace-fail 'path.join(process.resourcesPath, "server", "standalone", "server.js")' \
                     'path.join(__dirname, "..", "server", "standalone", "server.js")'

    substituteInPlace src/agent/subagents/headless.ts \
      --replace-fail 'process.versions.electron ? ["--browser-service"]' \
                     'process.versions.electron ? ["${finalAttrs.appDir}", "--browser-service"]'
  '';

  postBuild = ''
    node scripts/build-server.mjs
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $appDir/server $appDir/node_modules
    cp -r electron package.json $appDir/
    cp -r node_modules/jose $appDir/node_modules/
    cp -r .next/standalone $appDir/server/standalone

    makeWrapper ${lib.getExe electron_44} $out/bin/learnharness \
      --add-flags $appDir

    install -Dm644 build/icon.png $out/share/icons/hicolor/512x512/apps/learnharness.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "learnharness";
      desktopName = "LearnHarness";
      comment = finalAttrs.meta.description;
      exec = "learnharness %U";
      icon = "learnharness";
      categories = [ "Education" ];
      startupWMClass = "LearnHarness";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Agent harness for learning: adaptive teaching, practice, and a persistent knowledge graph";
    homepage = "https://github.com/amosblomqvist/learnharness";
    changelog = "https://github.com/amosblomqvist/learnharness/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "learnharness";
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = lib.platforms.linux;
  };
})
